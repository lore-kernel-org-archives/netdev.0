From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Cbe-oss-dev] [PATCH 0/18] spidernet driver bug fixes
Date: Fri, 8 Jun 2007 13:20:20 -0400
Message-ID: <20070608172020.GA31089@havoc.gtf.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57616 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761948AbXFHRUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 13:20:22 -0400
Content-Disposition: inline
In-Reply-To: <20070608170608.GI7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
> On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> > On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> > > Jeff, please apply for the 2.6.23 kernel tree.  The pach series
> > > consists of two major bugfixes, and several bits of cleanup.
> > > 
> > > The major bug fixes are: 
> > > 
> > > 1) a rare but fatal bug involving "RX ram full" messages, 
> > >    which results in a driver deadlock.
> > > 
> > > 2) misconfigured TX interrupts, causing a sever performance
> > >    degardation for small packets.
> > 
> > I realise it's late, but shouldn't "major bugfixes" be going into 22 ?
> 
> Yeah, I suppose, I admit I've lost track of the process. 
> 
> I'm not sure how to submit patches for this case. The "major fixes"
> are patches 6/18, 13/18 14/18 and 17/18; (the rest of the patches are 
> cruft-fixes). Taken alone, these four will not apply cleanly. 
> 
> I could prepare a new set, with just these four; asuming these are
> accepted into 2.6.22, then once 22 comes out, Jeff's .23 tree won't 
> merge cleanly.  

You need to order your bug fixes first in the queue.  I push those
upstream, and simultaneous merge the result into netdev#upstream (2.6.23
queue).

	Jeff



