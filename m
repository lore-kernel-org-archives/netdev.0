From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 1/2] tulip: fix for 64-bit mips
Date: Mon, 26 Jun 2006 15:07:40 -0700
Message-ID: <20060626220739.GG19196@goober>
References: <200606250845.k5P8j1Tt020829@shell0.pdx.osdl.net> <20060625093108.GA29132@unjust.cyrius.com> <20060625234400.GB29506@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Michlmayr <tbm@cyrius.com>, akpm@osdl.org, jeff@garzik.org,
	netdev@vger.kernel.org, maillist@jg555.com, pdh@colonel-panic.org,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:25223 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S933077AbWFZWKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 18:10:07 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060625234400.GB29506@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 25, 2006 at 05:44:00PM -0600, Grant Grundler wrote:
> On Sun, Jun 25, 2006 at 10:31:08AM +0100, Martin Michlmayr wrote:
> > * akpm@osdl.org <akpm@osdl.org> [2006-06-25 01:45]:
> > > Cc: Valerie Henson <val_henson@linux.intel.com>
> > > 
> > > [akpm: this is a previously-nacked patch, but the problem is real]
> 
> ia64 and parisc need the changes to tulip_select_media() too.
> 
> 
> > And, for the record, Jeff's suggestion as to how to rework the patch:
> > 
> > | Answer hasn't changed since this was last discussed:  sleep, rather than
> > | delay for an extra-long time.  That's the only hurdle for the tulip
> > | patches you keep resending.
> > 
> > | Francois Romieu even had an untested patch that attempted this,
> > | somewhere.
> > 
> > Now we just need someone to complete this work...
> 
> Kyle McMartin has the work queue patch merged into the cvs.parisc-linux.org
> CVS tree. It would be easiest to accept this patch and then add the
> tulip work queue patch next.

I like the work queue approach; I'll be talking with Kyle and Grant
about it.

> Note that the work queue does NOT solve all of the "spin delay with
> interrupts blocked" problems. tulip_stop_rxtx() polls for nearly as long
> and tulip_select_media().

Let's chat...

-VAL
