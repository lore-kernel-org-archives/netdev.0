From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Free the port memory
 directly with kfree instead of kfree_rcu
Date: Mon, 05 Dec 2016 22:53:10 -0800
Message-ID: <1481007190.18162.570.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480998547-9013-1-git-send-email-fgao@ikuai8.com>
         <1481005511.18162.564.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+6hz4pGw-+HvKVDCiFmXRd6YwioUXdZfOghtx0aFb6EPxcj5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34633 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbcLFGxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 01:53:13 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so18197410pfb.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 22:53:13 -0800 (PST)
In-Reply-To: <CA+6hz4pGw-+HvKVDCiFmXRd6YwioUXdZfOghtx0aFb6EPxcj5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 14:31 +0800, Gao Feng wrote:

> Because I don't fully hold the ipvlan codes now, I am afraid of that
> there is someone which may get the port address when
> ipvlan_port_destroy. So the original ipvlan_port_destroy uses the
> kfree_rcu to avoid it.
> 
> I am sure there is unnecessary to use kfree in ipvlan_port_create.

And I am pretty sure it is unnecessary to use kfree_rcu() in
ipvlan_port_destroy() as well.

I highly suggest you spend time on learning why.
