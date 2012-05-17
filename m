From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 18:49:47 +0200
Message-ID: <1337273387.3403.24.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39158 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965410Ab2EQQtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:49:52 -0400
Received: by eeit10 with SMTP id t10so594384eei.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 09:49:51 -0700 (PDT)
In-Reply-To: <20120517164016.GL14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 18:40 +0200, Willy Tarreau wrote:
>  try to port your patch (8d4057 tg3: provide frags as skb head) to
> mv643xx_eth as an exercise. If I succeed and notice an improvement, I'll
> send a patch :-)


tg3 uses build_skb(), thats an API that allocates the skb after frame is
filled by the device, to have less cache misses in RX path.

But for most devices, netdev_alloc_skb() would be more than enough.

I'll send a patch once tested.

Thanks
