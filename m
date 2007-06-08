From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH 0/18] spidernet driver bug fixes
Date: Fri, 8 Jun 2007 12:06:08 -0500
Message-ID: <20070608170608.GI7904@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40377 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968840AbXFHRGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 13:06:10 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58H69s7006175
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:06:09 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58H69IK335138
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:06:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58H68o2005018
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:06:09 -0400
Content-Disposition: inline
In-Reply-To: <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> > Jeff, please apply for the 2.6.23 kernel tree.  The pach series
> > consists of two major bugfixes, and several bits of cleanup.
> > 
> > The major bug fixes are: 
> > 
> > 1) a rare but fatal bug involving "RX ram full" messages, 
> >    which results in a driver deadlock.
> > 
> > 2) misconfigured TX interrupts, causing a sever performance
> >    degardation for small packets.
> 
> I realise it's late, but shouldn't "major bugfixes" be going into 22 ?

Yeah, I suppose, I admit I've lost track of the process. 

I'm not sure how to submit patches for this case. The "major fixes"
are patches 6/18, 13/18 14/18 and 17/18; (the rest of the patches are 
cruft-fixes). Taken alone, these four will not apply cleanly. 

I could prepare a new set, with just these four; asuming these are
accepted into 2.6.22, then once 22 comes out, Jeff's .23 tree won't 
merge cleanly.  

What's the right way to do this?

--linas
