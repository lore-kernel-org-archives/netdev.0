From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/15] netdevice: Convert directly reference of
 netdev->priv to netdev_priv()
Date: Wed, 03 Sep 2008 00:58:30 -0700 (PDT)
Message-ID: <20080903.005830.22785313.davem@davemloft.net>
References: <48B3D717.7070706@cn.fujitsu.com>
	<48BE4190.6060407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753388AbYICH6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 03:58:37 -0400
In-Reply-To: <48BE4190.6060407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 03 Sep 2008 15:49:36 +0800

> Wang Chen said the following on 2008-8-26 18:12:
> > Following patches will convert directly reference of netdev->priv to netdev_priv().
> > 
> > - Patch 1/15 is the safe convert which I believe will not make "after converted " worse
> > than "before converted".
> > 
> > - Patches 2-14 need comments. Since the value of netdev->priv is changed in drivers
> > and I use netdev->ml_priv to replace netdev->priv.
> > 
> 
> Dave, will you apply this for net-next? or give me your comment? :)

I'll see what I can do.

I know this is going to create conflicts in a few places, including sparc-next-2.6
where I already made this fix while cleaning up all of the SBUS device drivers.

So I guess I'm saying that I'm being lazy. :)

I'll try to look into this next week as I'm going to be busy and also away for
a few days.
