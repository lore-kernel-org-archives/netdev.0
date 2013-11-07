From: Peter Meerwald <pmeerw@pmeerw.net>
Subject: Re: BCM57786 driver
Date: Thu, 7 Nov 2013 13:36:21 +0100 (CET)
Message-ID: <alpine.DEB.2.01.1311071223070.4822@pmeerw.net>
References: <CAJZ9B5s87PHb3=eAxOy1dDo59Tq8pQbR78-=_zyKt8-0g5tGdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Joshua Richenhagen <richenhagen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.pmeerw.net ([87.118.82.44]:44802 "EHLO pmeerw.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab3KGMgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 07:36:23 -0500
In-Reply-To: <CAJZ9B5s87PHb3=eAxOy1dDo59Tq8pQbR78-=_zyKt8-0g5tGdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I recently bought a Acer Aspire E1-572 notebook with the gigabit
> ethernet controller Broadcom Corporation NetXtreme BCM57786 builtin.
> However I can't get it working under Ubuntu, neither with standard
> kernel nor with newest mainline kernel 3.12 final. I doesn't seem to
> be recognized at all, does a driver for this chip exists, or do I have
> to wait till one gets released? How far is the developmend process?

I have the same notebook and reported to the Ubuntu bug tracker 
(https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1182868)
solution for me is to add the PCI vendor/product IDs to the tg3 driver

there seems to be a fix in the upstream kernel, see 
http://patchwork.ozlabs.org/patch/276813/
already

hope the Ubuntu folk act on this

regards, p.


-- 

Peter Meerwald
+43-664-2444418 (mobile)
