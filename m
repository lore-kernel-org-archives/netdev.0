From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 0/15] netdevice: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Wed, 03 Sep 2008 15:49:36 +0800
Message-ID: <48BE4190.6060407@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56274 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYICHv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 03:51:59 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-8-26 18:12:
> Following patches will convert directly reference of netdev->priv to netdev_priv().
> 
> - Patch 1/15 is the safe convert which I believe will not make "after converted " worse
> than "before converted".
> 
> - Patches 2-14 need comments. Since the value of netdev->priv is changed in drivers
> and I use netdev->ml_priv to replace netdev->priv.
> 

Dave, will you apply this for net-next? or give me your comment? :)

