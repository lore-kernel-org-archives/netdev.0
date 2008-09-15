From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 17:24:59 -0400
Message-ID: <20080915212459.GE3994@havoc.gtf.org>
References: <20080915.120917.36004302.davem@davemloft.net> <20080915201749.GB3994@havoc.gtf.org> <20080915.132716.267218808.davem@davemloft.net> <20080915.141159.181213705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37085 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbYIOVZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 17:25:00 -0400
Content-Disposition: inline
In-Reply-To: <20080915.141159.181213705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 02:11:59PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 15 Sep 2008 13:27:16 -0700 (PDT)
> 
> > I'll take another look at the queue and try to give you some
> > more specific feedback.
> 
> 	Thomas Bogendoerfer (1):
> 	      tulip: Fix dead 21041 ethernet after ifconfig down
> 
> Not a regression, that problem has been there forever.

> 	Hannes Hering (1):
> 	      ehea: Fix DLPAR memory handling
> 
> No kernel bugzilla, no regression list entry, no way.
> 
> 	Krzysztof Halasa (1):
> 	      wan/hdlc_x25.c: fix a NULL dereference
> 
> Not a 2.6.27 regression, this problem has been there forever.

> So, as I said, the vast majority of this stuff is absolulte not
> appropriate.  Most of it can totally wait for 2.6.28, and not
> be merged now.
> 
> You can accelerate this process by making sure that every
> commit message has a reference to the regression list entry
> or a kernel bugzilla that the patch fixes.

So, my takeaway from this is...

1) Creating a bugzilla entry magically makes a bug fix acceptable?

2) We no longer want "this kills the driver" fixes?

I disagree with that logic, and I seriously doubt Linus wants to turn
away serious fixes to serious problems.  Many of these are clearly
needed, just read the extended patch description and the patch itself.

You just rejected patches that (a) fixed dead ethernet [de2104x], (b) fixed an
oops [WAN], and (c) fixed memory corruption [ehea].

I feel like I have just stepped into Odd World, if you don't want fixes
as serious as these.

	Jeff



