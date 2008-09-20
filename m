From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [V#2 PATCH 0/18] netdevice: Fix directly reference of netdev->priv
Date: Sat, 20 Sep 2008 16:17:52 +0800
Message-ID: <48D4B1B0.2030803@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49664 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbYITIUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2008 04:20:41 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-9-5 11:06:
> We have some reasons to kill netdev->priv:
> 1. netdev->priv is equal to netdev_priv().
> 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
>    netdev_priv() is more flexible than netdev->priv.
> But we cann't kill netdev->priv now, because so many drivers reference to it
> directly.
> 
> OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> and I want to kill netdev->priv later, I decided to convert all the direct
> reference of netdev->priv first.
> 
> - Patch 1-4 are the safe convert which I believe will not make "after converted " worse
>   than "before converted".
>   Originally, I put this kind of convert in one mail, but it's too big for vger.
>   So I split it to 4 parts and make every part smaller than 100,000 bytes,
>   which is max size allowed by vger.
> 
> - Patches 5-18 need comments. Since the value of netdev->priv is changed in drivers
>   and I use netdev->ml_priv to replace netdev->priv.
> 

Dave said:
> I'll see what I can do.
> 
> I know this is going to create conflicts in a few places, including sparc-next-2.6
> where I already made this fix while cleaning up all of the SBUS device drivers.
> 
> So I guess I'm saying that I'm being lazy. :)
> 
> I'll try to look into this next week as I'm going to be busy and also away for
> a few days.
> 

Dave, seems nobody give any opposite comments.
I know it's a boring job to look into this patch,
I hope I can buy you a cup of coffee ;)
But I still hope you can apply it or check it ASAP,
because the later you apply it the more conflicts.
Thank you.

