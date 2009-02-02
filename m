From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remaining bits for basic support of LDP
Date: Mon, 2 Feb 2009 22:29:09 +0000
Message-ID: <20090202222909.GC16069@n2100.arm.linux.org.uk>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk> <20090202.134530.63616213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony@atomide.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:56764 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758118AbZBBW3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 17:29:35 -0500
Content-Disposition: inline
In-Reply-To: <20090202.134530.63616213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 01:45:30PM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Mon, 2 Feb 2009 21:39:53 +0000
> 
> > The patch to fix these issues would seem to be relatively small (12
> > lines in the smc911x and one line change in board-ldp.c) - is it
> > something we want done for -rc4 or do we scrap the ethernet support 
> > on the LDP until the SMSC driver has been merged ?
> > 
> > Obviously, having working ethernet would be helpful, and since it was
> > half heartedly merged when the initial OMAP3 stuff went upstream we
> > should do something with it one way or another.
> 
> Well, the SMSC driver is there already in the tree.
>
> The only thing not currently being scheduled to hit
> 2.6.29-rcX are the recent changes to support platform
> specified interrupt flags and all of that stuff.
> 
> If you want, we can look into pushing that work into
> 2.6.29-rcX

Hmm.  Since we should assume that the other smc911x using platforms work
as-is, merging Steve's first four and the LDP patch seems to be a sane
idea.  We can queue the remainder for when bugs are reported or the
next merge window, whichever comes earlier.
