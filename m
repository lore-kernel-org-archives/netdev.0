From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Fri, 28 Mar 2008 22:21:05 -0400
Message-ID: <47EDA791.4090402@pobox.com>
References: <20080327140041.072611004@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Greg Ungerer <gerg@uclinux.org>
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51074 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756271AbYC2CVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:21:09 -0400
In-Reply-To: <20080327140041.072611004@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Siewior wrote:
> I got into this after turning on spinlock debugging.
> 
> Jeff: The dev->hard_start_xmit callback is always called from softirq
> context so it is save to use spin_lock_irq(), right?
> 
> Greg: The isr (fec_enet_rx()) calls three functions. All
> but fec_enet_rx() are grabbing the spinlock. Is this on purpose?

wanted for 2.6.25?  ACKs from maintainer?


