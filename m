From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Fri, 28 Mar 2008 22:19:38 -0400
Message-ID: <47EDA73A.5060902@pobox.com>
References: <20080327140041.072611004@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Greg Ungerer <gerg@uclinux.org>
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51059 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756111AbYC2CTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:19:55 -0400
In-Reply-To: <20080327140041.072611004@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Siewior wrote:
> I got into this after turning on spinlock debugging.
> 
> Jeff: The dev->hard_start_xmit callback is always called from softirq
> context so it is save to use spin_lock_irq(), right?

Some drivers do that, and it's fine.  But be aware spin_lock_irqsave() 
may be required for edge cases like netconsole.


