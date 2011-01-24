From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Mon, 24 Jan 2011 15:01:32 -0800 (PST)
Message-ID: <20110124.150132.183040805.davem@davemloft.net>
References: <1295470787.11126.82.camel@bwh-desktop>
	<1295470904.11126.84.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751829Ab1AXXA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:00:57 -0500
In-Reply-To: <1295470904.11126.84.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Jan 2011 21:01:44 +0000

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

I've pulled from Thomas's tree to get this commit into net-next-2.6,
thanks.
