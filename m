From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: pktgen: disable xmit_clone on virtual devices
Date: Sun, 22 Feb 2015 20:09:43 -0500
Message-ID: <CAMEtUuyBKhsVRwJDqxx62ZK+WE9TJKVQNihrjyA0cZyZJizuKg@mail.gmail.com>
References: <1424653421.5565.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:44122 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbBWBKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 20:10:05 -0500
Received: by mail-qa0-f53.google.com with SMTP id k15so20147695qaq.12
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 17:10:04 -0800 (PST)
In-Reply-To: <1424653421.5565.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2015 at 8:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Trying to use burst capability (aka xmit_more) on a virtual device
> like bonding is not supported.
>
> For example, skb might be queued multiple times on a qdisc, with
> various list corruptions.
>
> Fixes: 38b2cf2982dc ("net: pktgen: packet bursting via skb->xmit_more")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

thanks. good catch.
