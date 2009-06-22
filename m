From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of	queueing an
 extra skb.
Date: Mon, 22 Jun 2009 11:16:03 +0530
Message-ID: <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:41434 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZFVFuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:50:15 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n5M5oGxk012879
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 11:20:16 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5M5oGMS3010782
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 11:20:16 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n5M5oFGA028278
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 15:50:16 +1000
In-Reply-To: <20090619043613.GA15163@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

> Herbert Xu <herbert@gondor.apana.org.au> wrote on 06/19/2009 10:06:13 AM:
>
> > We either remove the API, or fix it.  I think fixing it is better,
because my
> > driver will be simpler and it's obvious noone wants to rewrite 50
drivers and
> > break several of them.
>
> My preference is obviously in the long term removal of TX_BUSY.
> Due to resource constraints that cannot be done immediately.  So
> at least we should try to stop its proliferation.
>
> BTW removing TX_BUSY does not mean that your driver has to stay
> complicated.  As I have said repeatedly your driver should be
> checking the stop-queue condition after transmission, not before.
>
> In fact queueing it in the driver is just as bad as return TX_BUSY!

I was curious about "queueing it in the driver" part: why is this bad? Do
you
anticipate any performance problems, or does it break QoS, or something
else I
have missed?

thanks,

- KK

