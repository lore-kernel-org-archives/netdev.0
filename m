From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Fri, 28 Mar 2008 16:51:35 +1000
Message-ID: <47EC9577.2090402@snapgear.com>
References: <20080327140041.072611004@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:42437 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753994AbYC1Gvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 02:51:47 -0400
In-Reply-To: <20080327140041.072611004@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastion,

Sebastian Siewior wrote:
> I got into this after turning on spinlock debugging.
> 
> Jeff: The dev->hard_start_xmit callback is always called from softirq
> context so it is save to use spin_lock_irq(), right?
> 
> Greg: The isr (fec_enet_rx()) calls three functions. All
                 (fec_enet_interrupt())
> but fec_enet_rx() are grabbing the spinlock. Is this on purpose?

No, it looks broken :-(

Regards
Greg



-- 
------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
Secure Computing Corporation                PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
