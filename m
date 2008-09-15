From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 18:34:07 -0400
Message-ID: <20080915223407.GB15421@havoc.gtf.org>
References: <20080915.132716.267218808.davem@davemloft.net> <20080915.141159.181213705.davem@davemloft.net> <20080915212459.GE3994@havoc.gtf.org> <20080915.150746.24873255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56538 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753273AbYIOWeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 18:34:08 -0400
Content-Disposition: inline
In-Reply-To: <20080915.150746.24873255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 03:07:46PM -0700, David Miller wrote:
> > You just rejected patches that (a) fixed dead ethernet [de2104x],
> 
> And it's getting submitted now, because?!?
> 
>  (b) fixed an
> > oops [WAN], and
> 
> It's WAN, it's been there forever, who cares and why now?
> 
> > (c) fixed memory corruption [ehea].
> 
> Again, it's been there for quite some time, why is it "now"
> all of sudden now important to integrate this fix?

Because users should not be forced to wait 3 months for fixes, for
admittedly serious bugs, which are ready for them right now.  Small,
self-contained, tested, obvious fixes.

There is just something horribly wrong if you are not taking two-line
fixes for memory corruption, even if the problem existed since
kernel 1.2.13.

	July 13:	2.6.26 released, merge window opens
	July 29:	2.6.27-rc1 released, merge window closes
	Sept 20?	2.6.27 release (wild guess)
	Dec 25?		2.6.28 release (wild guess)

So if a small, easily-mergable fix for a major bug like an oops
appears on July 30, being strict to your plan has this fix waiting
until almost 2009 (2.6.28 release), a wait of over five months.

That is not serving Linux users, our primary customers.

Complaining about the 8139too change, I can see that (even though
Linus takes that stuff via libata all the time).  But about memory
corruption and oopses?  Come on.

	Jeff



