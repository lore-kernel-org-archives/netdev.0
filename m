From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 6 Feb 2009 09:42:53 +0000
Message-ID: <20090206094253.GB4879@ff.dom.local>
References: <20090203094108.GA4639@ff.dom.local> <20090205.235258.257422341.davem@davemloft.net> <20090206091034.GA4879@ff.dom.local> <20090206.011722.41272682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:45213 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbZBFJnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:43:00 -0500
Content-Disposition: inline
In-Reply-To: <20090206.011722.41272682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 01:17:22AM -0800, David Miller wrote:
...
> And all I'm saying is that since the page allocator provides that
> facility, and using pages solves all of the splice() et al.  problems,
> building something extremely simple on top of the page allocator seems
> to be a good way to go.

This all is absolutely right if we can afford it: more simple - more
memory wasted. I hope you're right, but on the other hand, people
don't use slob by default.

Jarek P.
