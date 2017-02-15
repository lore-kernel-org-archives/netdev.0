From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] tcp: tcp_probe: use spin_lock_bh()
Date: Tue, 14 Feb 2017 22:24:10 -0800
Message-ID: <20170214222410.5ccbd61d@plumbers-lap.home.lan>
References: <20170214172858.07d4393a@darkbook.lan.box>
        <20170214.144648.771654199689384203.davem@davemloft.net>
        <CAMyjOU+1CAC-VLL0JBABnbzWGZPLncqy6jXWQpVkd6vnXi-3pA@mail.gmail.com>
        <1487121074.8227.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35284 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdBOGYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 01:24:14 -0500
Received: by mail-pf0-f174.google.com with SMTP id 202so25959406pfx.2
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 22:24:13 -0800 (PST)
In-Reply-To: <1487121074.8227.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2017 17:11:14 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_rcv_established() can now run in process context.
> 
> We need to disable BH while acquiring tcp probe spinlock,
> or risk a deadlock.
> 
> Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>

Thanks. Also glad to see people are still using TCP probe.
