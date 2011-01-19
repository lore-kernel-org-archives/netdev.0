From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Wed, 19 Jan 2011 22:19:04 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6>
References: <1295470787.11126.82.camel@bwh-desktop> <1295470904.11126.84.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:57655 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab1ASVTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 16:19:19 -0500
In-Reply-To: <1295470904.11126.84.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B1;2401;0cOn Wed, 19 Jan 2011, Ben Hutchings wrote:

> When initiating I/O on a multiqueue and multi-IRQ device, we may want
> to select a queue for which the response will be handled on the same
> or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add a
> notification mechanism to support this.
> 
> This is based closely on work by Thomas Gleixner <tglx@linutronix.de>.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Thomas, I hope this answers all your comments.  If you are happy with
> this, can it go into net-next-2.6 so the rest of this series can get
> into 2.6.39?

Looks good, but I prefer to take it via the tip/genirq branch as I
have other changes pending to that code. I'll put this into a separate
branch based on rc1 as a single commit so Dave can pull that branch
into netdev. Dave ?

Thanks,

	tglx
