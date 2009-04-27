From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Mon, 27 Apr 2009 09:41:03 +0400
Message-ID: <20090427054103.GA27529__24892.6570559435$1240824321$gmane$org@night.netis.ru>
References: <20090422055735.GA4334@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, linux-netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:44821 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbZD0IFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 04:05:38 -0400
Received: from night.yars.free.net (localhost [127.0.0.1])
	by night.yars.free.net (8.14.3/8.14.3) with ESMTP id n3R7QtXe002381
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 11:26:55 +0400 (MSD)
Received: (from lav@localhost)
	by night.yars.free.net (8.14.3/8.14.3/Submit) id n3R7Qsge002380
	for netdev@vger.kernel.org; Mon, 27 Apr 2009 11:26:54 +0400 (MSD)
Content-Disposition: inline
In-Reply-To: <20090422055735.GA4334@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 09:57:35AM +0400, Alexander V. Lukyanov wrote:
> unregister_netdevice: waiting for eth0.2 to become free. Usage count = 4
> 
> eth0.2 is a vlan interface, eth0 is 02:00.0 Ethernet controller: Realtek
> Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet
> controller (rev 01)

Ok, now I did manually 'vconfig rem eth0.2' and I get these repeated messages.
How do I find out what exactly holds the interface being used?

I have killed most of non-kernel processes, eth0.2 is still used. LA=1, but
the cpu is idle.

top - 09:34:26 up 4 days, 23:55,  2 users,  load average: 1.00, 1.12, 3.55
Tasks:  56 total,   1 running,  55 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.2%us,  0.2%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   3356308k total,  1165044k used,  2191264k free,   443536k buffers
Swap:  3212920k total,      712k used,  3212208k free,   493568k cached

-- 
   Alexander..
