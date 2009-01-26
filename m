From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 26 Jan 2009 09:12:27 +0100
Message-ID: <20090126081227.GA4774@1wt.eu>
References: <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net> <20090119101924.GA1881@gondor.apana.org.au> <20090119.125941.240930524.davem@davemloft.net> <20090125210325.GA31227@1wt.eu> <20090126075932.GA4183@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1798 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbZAZINE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 03:13:04 -0500
Content-Disposition: inline
In-Reply-To: <20090126075932.GA4183@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 07:59:33AM +0000, Jarek Poplawski wrote:
> On Sun, Jan 25, 2009 at 10:03:25PM +0100, Willy Tarreau wrote:
> ...
> > The memory allocation clearly is the culprit here. I'll try Jarek's
> > patch which reduces memory allocation to see if that changes something,
> > as I'm sure we can do fairly better, given how it behaves with limited
> > sessions.
> 
> I think you are right, but I wonder if it's not better to wait with
> more profiling until this splicing is really redone.

Agreed. In fact I have run a few tests even with your patch and I could
see no obvious figure starting to appear. I'll go back to 2.6.27-stable
+ the fixes because I don't really know what I'm testing under 2.6.29-rc2.
Once I'm able to get reproducible reference numbers, I'll test again
with the latest kernel.

Regards,
Willy

