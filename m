From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Wed, 9 Dec 2015 16:29:23 +0100
Message-ID: <20151209152923.GL13328@lunn.ch>
References: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
 <20151209030729.GA2093@lunn.ch>
 <20151209143951.GM22885@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33996 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbbLIP3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 10:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20151209143951.GM22885@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Originally the interrupt is used for detecting the link has gone
> > down. That would of also been bogus before. Have you tried this?  If
> 
> Haven't tried it, but chances are you are right.
> 
> > that is also broken, maybe you need to add a fixes: tag so that it
> > gets back ported?
> 
> Nobody noticed in the past ~7 years or so, but I guess I can point Greg
> at it once it is present in mainline.  The main reason I'd Cc'd netdev
> is just to possibly save anyone else the investigation if they ran into
> the same issue on a different board -which seems highly probable IMHO.

Yes, you are probably right about other boards. So this change might
be considered as causing a regression. But if they are already broken,
because link down does not work, there might be less demand to get the
change reverted....

       Andrew
