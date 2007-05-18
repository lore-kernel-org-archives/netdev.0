From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH 2/10] spidernet: beautify error messages
Date: Fri, 18 May 2007 12:08:38 -0500
Message-ID: <20070518170838.GO4325@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com> <20070516220011.GB4997@austin.ibm.com> <1179358133.4142.1.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46535 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756990AbXERRIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 13:08:45 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4IH8hJU012841
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 13:08:43 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4IH8dcb264766
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 11:08:42 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4IH8dmR031104
	for <netdev@vger.kernel.org>; Fri, 18 May 2007 11:08:39 -0600
Content-Disposition: inline
In-Reply-To: <1179358133.4142.1.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2007 at 09:28:53AM +1000, Michael Ellerman wrote:
> On Wed, 2007-05-16 at 17:00 -0500, Linas Vepstas wrote:
> > -			pr_err("Not enough memory to allocate rx buffer\n");
> > +			pr_err("%s: Not enough memory to allocate rx buffer\n",
> > +			    card->netdev->name);
> 
> Isn't that what dev_err() is for?

Ahh, did not know that. These patches just got pushed upstream, I'll send 
a separate round to clean this up.

--linas


