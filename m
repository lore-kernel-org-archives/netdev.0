From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:32:19 +0000
Message-ID: <20071113193219.GC1356@flint.arm.linux.org.uk>
References: <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113.043207.44732743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:55446 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbXKMTcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 14:32:50 -0500
Content-Disposition: inline
In-Reply-To: <20071113.043207.44732743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 04:32:07AM -0800, David Miller wrote:
> Luckily if the report being ignored isn't chaff, it will show up again
> (and again and again) and this triggers a reprioritization because not
> only is the bug no longer chaff, it also now got a lot of information
> tagged to it so it's a double worthwhile investment to work on the
> problem.

Strongly agree.

This is exactly what happened to that ARM NO_HZ bug report.  The report
in bugzilla was rather lacking (and wrong) in ways that have already
been described.  HPET on ARM? 8)

Then on the morning of 6th November, someone reported on the mailing list
that "pxa270 doesn't work with oneshot timer" and that was the trigger to
getting the bug resolved - because it was a narrowly defined bug report.

Since it was a narrowly defined bug report, it became very easy to
investigate and resolve.  About half an hour of time for an initial
patch.


There's another issue I want to raise concerning bugzilla.  We have the
classic case of "not enough people reading bugzilla bugs" - which is one
of the biggest problems with bugzilla.  Virtually no one in the ARM
community looks for ARM bugs in bugzilla.

Let's not forget that it would be a waste of time for people to manually
check bugzilla for ARM bugs.  There's soo few people reporting ARM bugs
into bugzilla that a weekly manual check by every maintainer would just
return the same old boring results for months and months at a time.

It would be far more productive if the ARM category was deleted from
bugzilla and the few people who use bugzilla reported their bugs on the
mailing list.  We've a couple of thousand people on the ARM kernel
mailing list at the moment - that's 3 orders of magnitude more of eyes
than look at bugzilla.

(I'm not saying that if the ARM NO_HZ bug as reported in bugzilla had
been reported on the correct mailing list would've been solved earlier;
I doubt there'd be much difference.  However, the probability of a
question being asked of the reporter would've been much higher, and
_that_ might have led to an earlier resolution.)

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
