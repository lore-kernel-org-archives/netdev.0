From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 13:25:37 +0000
Message-ID: <20090203132537.GC4639@ff.dom.local>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203123628.GB4639@ff.dom.local> <20090203130606.GA25471@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:10811 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbZBCNZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 08:25:46 -0500
Content-Disposition: inline
In-Reply-To: <20090203130606.GA25471@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 04:06:06PM +0300, Evgeniy Polyakov wrote:
> On Tue, Feb 03, 2009 at 12:36:28PM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > I understand NTA could be better than slabs in above-mentioned cases,
> > but I'm not sure you explaind enough your point on solving this
> > zero-copy problem vs. NTA?
> 
> NTA steals pages from the SLAB so we can maintain any reference counter
> logic in them, so linear part of the skb may be not really freed/reused
> until reference counter hits zero.

Now it's clear. So this looks like one of the options considered by
David. Then I wonder about details... It seems some kind of scheduled
browsing for refcounts is needed or is there something better?

Jarek P.
