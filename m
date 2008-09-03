From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 0/15] netdevice: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Wed, 03 Sep 2008 16:24:21 +0800
Message-ID: <48BE49B5.8070509@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>	<48BE4190.6060407@cn.fujitsu.com> <20080903.005830.22785313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59512 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751497AbYICI0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 04:26:51 -0400
In-Reply-To: <20080903.005830.22785313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-9-3 15:58:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 03 Sep 2008 15:49:36 +0800
> 
>> Wang Chen said the following on 2008-8-26 18:12:
>>> Following patches will convert directly reference of netdev->priv to netdev_priv().
>>>
>>> - Patch 1/15 is the safe convert which I believe will not make "after converted " worse
>>> than "before converted".
>>>
>>> - Patches 2-14 need comments. Since the value of netdev->priv is changed in drivers
>>> and I use netdev->ml_priv to replace netdev->priv.
>>>
>> Dave, will you apply this for net-next? or give me your comment? :)
> 
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

OK. Thank your.

