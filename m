From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Sat, 17 May 2008 06:18:46 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805170607190.4049@cliff.in.clinika.pl>
References: <1210695378.13845.362.camel@localhost.localdomain>
 <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
 <1210804791.13845.423.camel@localhost.localdomain>
 <Pine.LNX.4.55.0805142354530.15223@cliff.in.clinika.pl>
 <1210885435.13845.512.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:62538 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751471AbYEQFSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 01:18:53 -0400
In-Reply-To: <1210885435.13845.512.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Nate Case wrote:

> Fixed this in patch v3 (coming up shortly).

 This one works for me as well.  However I have noticed a couple of
unnecessary "inline" annotations.  I think it is best to leave the
decision about inlining up to the compiler -- remember that for Linux
"inline" expands to "inline __attribute__((always_inline))".  I have
updated the patch on your behalf to save you the hassle with another
iteration and will send it separately straight away, together with a few
trivial formatting adjustments.  Let me know if you disagree with any of
these changes.

 While doing this I have checked the relevant Kconfig file and noticed the 
new PHY models are not mentioned -- I will send another patch separately.

> I didn't try forcing speeds from userspace, but the worst I can envision
> happening is that after forcing 10mbit/s or half-duplex mode (for
> example) it would still report 1000mbit/s FD.  The forcing itself would
> probably not report an error, though you could argue that it should.  My
> understanding is that the hardware will take the writes but ignore those
> registers in 1000Base-X mode.

 Please try when you have some opportunity.  Personally I think an error
is not strictly necessary as long as the status read back is correct.

  Maciej
