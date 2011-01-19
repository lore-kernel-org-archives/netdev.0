From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Wed, 19 Jan 2011 13:27:30 -0800 (PST)
Message-ID: <20110119.132730.57462002.davem@davemloft.net>
References: <1295470787.11126.82.camel@bwh-desktop>
	<1295470904.11126.84.camel@bwh-desktop>
	<alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41068
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752356Ab1ASV05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 16:26:57 -0500
In-Reply-To: <alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 19 Jan 2011 22:19:04 +0100 (CET)

> B1;2401;0cOn Wed, 19 Jan 2011, Ben Hutchings wrote:
> 
>> When initiating I/O on a multiqueue and multi-IRQ device, we may want
>> to select a queue for which the response will be handled on the same
>> or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add a
>> notification mechanism to support this.
>> 
>> This is based closely on work by Thomas Gleixner <tglx@linutronix.de>.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>> Thomas, I hope this answers all your comments.  If you are happy with
>> this, can it go into net-next-2.6 so the rest of this series can get
>> into 2.6.39?
> 
> Looks good, but I prefer to take it via the tip/genirq branch as I
> have other changes pending to that code. I'll put this into a separate
> branch based on rc1 as a single commit so Dave can pull that branch
> into netdev. Dave ?

But if you do that what happens down the line when Linus pulls our trees
in?

If he takes your tip/genirq first, I have merge hassles to deal with.

If he takes the -rc1 relative version I end up with, you'll have the
merge hassles.
