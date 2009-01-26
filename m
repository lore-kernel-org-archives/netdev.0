From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 26 Jan 2009 07:59:33 +0000
Message-ID: <20090126075932.GA4183@ff.dom.local>
References: <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net> <20090119101924.GA1881@gondor.apana.org.au> <20090119.125941.240930524.davem@davemloft.net> <20090125210325.GA31227@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:56268 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbZAZH7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 02:59:40 -0500
Content-Disposition: inline
In-Reply-To: <20090125210325.GA31227@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2009 at 10:03:25PM +0100, Willy Tarreau wrote:
...
> The memory allocation clearly is the culprit here. I'll try Jarek's
> patch which reduces memory allocation to see if that changes something,
> as I'm sure we can do fairly better, given how it behaves with limited
> sessions.

I think you are right, but I wonder if it's not better to wait with
more profiling until this splicing is really redone.

Regards,
Jarek P.
