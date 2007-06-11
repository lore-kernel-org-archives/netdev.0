From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/15] spidernet driver bug fixes
Date: Mon, 11 Jun 2007 13:14:29 -0500
Message-ID: <20070611181429.GA4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:43506 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbXFKSOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:14:40 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIEdUF023834
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:14:39 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIEdKS145058
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:14:39 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIEcfb018814
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:14:38 -0600
Content-Disposition: inline
In-Reply-To: <20070608172020.GA31089@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
> On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
> > On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> > > On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> > > > 
> > > > The major bug fixes are: 
> > > I realise it's late, but shouldn't "major bugfixes" be going into 22 ?
> > Yeah, I suppose, I admit I've lost track of the process. 
>
> You need to order your bug fixes first in the queue. 

OK, here are the patches, re-ordered. There is a different number
than last time, as I threw out one, merged one, and got cold feet
on a third one.  They still pass the tests.

The first five patches focus on three serious bugs, fixing crashes or
hangs.

-- patch 1 -- kernel crash when ifdown while receiving packets.
-- patch 2,3,4 -- device driver deadlocks on "RX ram full" mesgs.
                  (kernel stays up, ifdown/up clear the problem).
-- patch 5 -- misconfigured TX interrupts results in 3x-4x per
              degradation for small packets.

-- patch 6 -- rx stats may be mangled
-- patch 7 -- hw checksum sometimes breaks ipv6 operation

-- patches 8-15 -- misc tweaks, and documentation.


I re-ran my stress tests with patches 1-7 applied; they pass.

I suggest that patches 1-5 or 1-7 be applied asap.

--linas
