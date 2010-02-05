From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Thu, 04 Feb 2010 16:17:00 -0800
Message-ID: <1265329020.31059.18.camel@w-sridhar.beaverton.ibm.com>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
	 <20100205000816.GA9575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:58670 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933503Ab0BEARD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 19:17:03 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1506pQU029863
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 19:06:51 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o150H2GH2048066
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 19:17:02 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o150H2Y2005442
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 19:17:02 -0500
In-Reply-To: <20100205000816.GA9575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-05 at 11:08 +1100, Herbert Xu wrote:
> On Wed, Feb 03, 2010 at 03:22:20PM -0800, Sridhar Samudrala wrote:
> >
> > - protocol value is assumed to be passed in by the caller.
> 
> So how is the caller going to pass the protocol value through?

via sockaddr_ll->sll_protocol in msg->msg_name.

Thanks
Sridhar


