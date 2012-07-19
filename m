From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 10/16] ipv4: Cache output routes in fib_info nexthops.
Date: Fri, 20 Jul 2012 00:19:22 +0200
Message-ID: <1342736362.2626.5443.camel@edumazet-glaptop>
References: <20120719.143540.747492487297004222.davem@davemloft.net>
	 <1342735743.2626.5411.camel@edumazet-glaptop>
	 <20120719.151312.1882340232448320251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:49246 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab2GSWT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 18:19:28 -0400
Received: by vbbff1 with SMTP id ff1so2407395vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 15:19:28 -0700 (PDT)
In-Reply-To: <20120719.151312.1882340232448320251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 15:13 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 20 Jul 2012 00:09:03 +0200
> 
> > If we find orig not null, what can protect another cpu from reading
> > nh->nh_rth_output, then we dst_release(orig), and other cpu  does the
> > dst_use() too late ?
> 
> Indeed, we'd have to defer it somehow.
> 
> Actually, we might be able to fake this by using __dst_free() on it
> or something similar.
> 
> But safest would be RCU, whose protection we are still using on the
> read side.
> 
> Any better ideas?

Well, its very late for me in France and I really need to sleep.

I hope I really can, now that you gave me the silly idea to work on a
linux patch ;)

RCU seems a good idea at first glance.
