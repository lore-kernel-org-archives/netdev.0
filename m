From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 4/15] spidernet: silence the ramfull messages
Date: Thu, 14 Jun 2007 17:29:43 -0500
Message-ID: <20070614222943.GY4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611182650.GD13741@austin.ibm.com> <46704F90.7050508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:40786 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbXFNW3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 18:29:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EMTjPn012819
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:29:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EMTicC531904
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:29:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EMTiJK008025
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 18:29:44 -0400
Content-Disposition: inline
In-Reply-To: <46704F90.7050508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 04:12:00PM -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 
> >10:02:34.000000000 -0500
> >+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 
> >11:45:25.000000000 -0500
> >@@ -1172,7 +1172,7 @@ spider_net_decode_one_descr(struct spide
> > 		goto bad_desc;
> > 	}
> > 
> >-	if (hwdescr->dmac_cmd_status & 0xfefe) {
> >+	if (hwdescr->dmac_cmd_status & 0xfcf4) {
> > 		pr_err("%s: bad status, cmd_status=x%08x\n",
> > 			       card->netdev->name,
> > 			       hwdescr->dmac_cmd_status);
> 
> 
> A follow-up patch needs to remove the above magic numbers (==numeric 
> constants), replacing them with named constants

I thought laziness was a virtue ... oh, wait, wrong programming language.

Patch coming shortly.

--linas
