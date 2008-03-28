From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH / RFC 2/2] fec: fixup spinlocks.
Date: Fri, 28 Mar 2008 10:24:40 +0100
Message-ID: <20080328092440.GC27124@www.tglx.de>
References: <20080327140041.072611004@linutronix.de> <20080327140120.068976876@linutronix.de> <47EC9701.4090504@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:57597 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbYC1JZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:25:46 -0400
Content-Disposition: inline
In-Reply-To: <47EC9701.4090504@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Greg Ungerer | 2008-03-28 16:58:09 [+1000]:

>Hi Sebastion,
Hi Greg,

>>4. Use the .*_irqsave variant in that part which may be called from IRQ or
>>user mode.
>
>I couldn't see any changes here that switched to use *_irqsave?
The only lock user that may be called from both called from both places
is mii_queue() and that one allready uses the save variant.
I guess you want me to repost that patch without point 4 in the summary
right?

>Regards
>Greg
Sebastian
