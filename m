From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Thu, 27 Mar 2008 15:00:41 +0100
Message-ID: <20080327140041.072611004@linutronix.de>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Greg Ungerer <gerg@uclinux.org>
To: uclinux-dev@uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42823 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756680AbYC0OLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 10:11:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got into this after turning on spinlock debugging.

Jeff: The dev->hard_start_xmit callback is always called from softirq
context so it is save to use spin_lock_irq(), right?

Greg: The isr (fec_enet_rx()) calls three functions. All
but fec_enet_rx() are grabbing the spinlock. Is this on purpose?

Sebastian
-- 

