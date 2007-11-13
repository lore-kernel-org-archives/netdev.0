From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:37:50 +0000
Message-ID: <20071113193750.GD1356@flint.arm.linux.org.uk>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Mark Lord <liml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54625 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758534AbXKMTiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 14:38:14 -0500
Content-Disposition: inline
In-Reply-To: <4739AFE0.20705@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 09:08:32AM -0500, Mark Lord wrote:
> Ingo Molnar wrote:
> ..
> > This is all QA-101 that _cannot be argued against on a rational basis_, 
> > it's just that these sorts of things have been largely ignored for 
> > years, in favor of the all-too-easy "open source means many eyeballs and 
> > that is our QA" answer, which is a _good_ answer but by far not the most 
> > intelligent answer! Today "many eyeballs" is simply not good enough and 
> > nature (and other OS projects) will route us around if we dont change.
> ..
> 
> QA-101 and "many eyeballs" are not at all in opposition.
> The latter is how we find out about bugs on uncommon hardware,
> and the former is what we need to track them and overall quality.
> 
> A HUGE problem I have with current "efforts", is that once someone
> reports a bug, the onus seems to be 99% on the *reporter* to find
> the exact line of code or commit.  Ghad what a repressive method.

99% on the reporter?  Is that why I always try to understand the
reporters problem (*provided* it's in an area I know about) and come
up with a patch to test a theory or fix the issue?

I'm _less_ inclined to provide such a "service" for lazy maintainers
who've moved off into new and wonderfully exciting technologies, to
churn out more patches for me to merge (and eventually provide a free
to them bug fixing service for.)

That's "less" inclined, not "won't".

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
