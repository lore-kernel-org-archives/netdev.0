From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/15] spidernet: null out skb pointer after its been used.
Date: Thu, 14 Jun 2007 17:00:54 -0500
Message-ID: <20070614220054.GW4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <46704F29.8060805@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36489 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbXFNWA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 18:00:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EM0tY0002975
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:00:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EM0tNI464988
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:00:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EM0s79024440
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:00:55 -0400
Content-Disposition: inline
In-Reply-To: <46704F29.8060805@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 04:10:17PM -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >Avoid kernel crash in mm/slab.c due to double-free of pointer.
> >
> >If the ethernet interface is brought down while there is still
> >RX traffic in flight, the device shutdown routine can end up
> >trying to double-free an skb, leading to a crash in mm/slab.c
> >Avoid the double-free by nulling out the skb pointer.
> >
> >Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> >
> >----
> > drivers/net/spider_net.c |    1 +
> > 1 file changed, 1 insertion(+)
> 
> applied 1-5, 7 to #upstream-fixes (2.6.22)
> 
> patch #6 was ignored, because it was already upstream

Thank you!

--linas
