From: Willy Tarreau <w@1wt.eu>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Wed, 16 Jan 2008 21:04:58 +0100
Message-ID: <20080116200458.GC8953@1wt.eu>
References: <20080115202905.GA2680@ami.dom.local> <E1JEvxs-0006cZ-00@gondolin.me.apana.org.au> <20080116065836.GA1638@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, cfriesen@nortel.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1345 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772AbYAPU0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 15:26:41 -0500
Content-Disposition: inline
In-Reply-To: <20080116065836.GA1638@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 07:58:36AM +0100, Jarek Poplawski wrote:
> On Wed, Jan 16, 2008 at 11:17:08AM +1100, Herbert Xu wrote:
> ...
> > Well people are always going to operate on this model for commercial
> > reasons.  FWIW I used to work for a company that stuck to a specific
> > version of the Linux kernel, and I suppose I still do even now :)
> > 
> > But the important thing is that if you're going to do that, then the
> > cost that comes with it should be borne by the company and not the
> > community.
> 
> Sure. But the most sad thing is there seems to be not so much savings
> in this (unless a company isn't sure of its near future). Trying to
> upgrade and test current products with current kernels, even if not
> necessary, should be always useful and make developing of new products
> faster and better fit (and of course, BTW, make the kernel better on
> time).

you can work with latest release provided that you always have a fallback
to an earlier one. That way, you don't bet too much on something you don't
completely control. If it works, it tells you you'll be able to completely
exploit its new possibilities in next product release, and if it breaks,
it's easy to issue a fix to get back to earlier, well-tested version.

Regards,
Willy

