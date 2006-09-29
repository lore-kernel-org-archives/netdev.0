From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 28 Sep 2006 17:28:27 -0700 (PDT)
Message-ID: <20060928.172827.26929236.davem@davemloft.net>
References: <20060928155052.63ed5ce8@freekitty>
	<20060928.160458.00452499.davem@davemloft.net>
	<20060928162704.55e863ca@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46289
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161222AbWI2A2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 20:28:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060928162704.55e863ca@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 28 Sep 2006 16:27:04 -0700

> It got added by this:
> 
> commit 0844565fb8a9418f5a860aa480c1aef70319c9a2
> Author: Thomas Graf <tgraf@suug.ch>
> Date:   Fri Aug 4 23:05:56 2006 -0700
> 
>     [NET]: Move netlink interface bits to linux/if.h
>     
>     Signed-off-by: Thomas Graf <tgraf@suug.ch>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Stephen, we just removed the troublesome bits from linux/if.h when I
put in Yoshifuji's patches last night, it should explicitly remove
this problem.

You will thus see that linux/rtnetlink.h no longer includes
linux/if.h, which is why your errors were completely perplexing
to me.  Instead, it includes linux/if_link.h

It's been in my tree since last night, and if you had used
the rtnetlink.h from my current tree you wouldn't have seen
the error.
