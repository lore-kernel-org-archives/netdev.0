From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Sun, 28 Feb 2016 06:55:57 +0100
Message-ID: <1456638957.3676.12.camel@gmail.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D1E8B6.6090003@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-02-27 at 10:19 -0800, Peter Hurley wrote:
> Hi Eric,
> 
> For a while now, we've been struggling to understand why we've been
> observing missed uart rx DMA.
> 
> Because both the uart driver (omap8250) and the dmaengine driver
> (edma) were (relatively) new, we assumed there was some race between
> starting a new rx DMA and processing the previous one.

Hrm, relatively new + tasklet woes rings a bell.  Ah, that..

<quote>
What's worse is that at the point where this code was written it was
already well known that tasklets are a steaming pile of crap and
should die.
</quote>

Source thereof https://lwn.net/Articles/588457/

	-Mike
