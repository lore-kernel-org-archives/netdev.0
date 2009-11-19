From: Jens Rosenboom <me@jayr.de>
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Thu, 19 Nov 2009 19:36:07 +0100
Message-ID: <20091119183607.GK14661@jayr.de>
References: <20091119163908.GJ14661@jayr.de> <7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Rosenboom <me@jayr.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout1.freenet.de ([195.4.92.91]:55142 "EHLO mout1.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978AbZKSSgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 13:36:15 -0500
Content-Disposition: inline
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2009 at 10:07:21AM -0800, Dhananjay Phadke wrote:
> > My netxen 10G card stops working somewhere between 2.6.30 and 2.6.31-rc1.
> > With the
> > newer kernel I can see packets been received on the switch it is
> > connected to, but
> > the kernel doesn't report any sent packets in the interface counters and
> > nothing
> > is being received either.
> > 
> > I've tried to bisect this, but only seems the end up with kernels that do
> > not boot
> > at all because some SCSI stuff goes bad.
> 
> Any particular reason for using -rc1 kernel and not 2.6.31 stable kernel?

Sorry, I forgot to mention that all later kernels that I tested
including 2.6.31 and the current net-2.6 also fail, so the badness 
comes in somewhere in between 2.6.30 and 2.6.31-rc1.

I also noticed that the newer kernel allocate four interrupts for the
card instead of only one, but none of them seem to get triggered, the
/proc/interrupts counters all stay at zero.
