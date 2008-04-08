From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Tue, 08 Apr 2008 02:30:09 -0700 (PDT)
Message-ID: <20080408.023009.223054390.davem@davemloft.net>
References: <20080403.114333.77827256.yoshfuji@linux-ipv6.org>
	<b25312890804050348w24bcba83y7391c89b1a9b25bc@mail.gmail.com>
	<20080405.224623.15818365.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: roszenrami@gmail.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbYDHJaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 05:30:08 -0400
In-Reply-To: <20080405.224623.15818365.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 05 Apr 2008 22:46:23 +0900 (JST)

> In article <b25312890804050348w24bcba83y7391c89b1a9b25bc@mail.gmail.com> (at Sat, 5 Apr 2008 13:48:30 +0300), "Rami Rosen" <roszenrami@gmail.com> says:
> 
> > It seems to me that this could be solved by calling skb_tail_pointer(), thus:
> > nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
> 
> Good point, thanks.
> 
> I've pushed the following fix into the tree:
> 	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-mroute-20080405
> on top of current net-2.6.26 tree.

Pulled and pushed back out to net-2.6.26

Thanks!
