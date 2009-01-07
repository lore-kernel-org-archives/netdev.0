From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 13:10:57 +0000
Message-ID: <20090107131057.GD9677@ff.dom.local>
References: <20090107115605.GA29250@ioremap.net> <20090107115921.GA25323@gondor.apana.org.au> <20090107121530.GA30164@ioremap.net> <20090107122238.GB25673@gondor.apana.org.au> <20090107123741.GA31255@ioremap.net> <20090107124246.GA26034@gondor.apana.org.au> <20090107124629.GA31732@ioremap.net> <20090107125535.GC6307@1wt.eu> <20090107125734.GA26331@gondor.apana.org.au> <20090107130259.GB32336@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Willy Tarreau <w@1wt.eu>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:39228 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbZAGNLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 08:11:07 -0500
Content-Disposition: inline
In-Reply-To: <20090107130259.GB32336@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 04:02:59PM +0300, Evgeniy Polyakov wrote:
...
> If I understood correctly Jarek's patch, he wants to allocate a page and
> copy linear content of the skb there, so this will end up being the same
> case as with splicing from the file. And while generally this may be a
> good idea, but with usual 1.5k mtu this will copy every skb, which is
> rather bad idea. Will have to think :)
> 

As I mentioned earlier, I (poorly) tried to realize Changli's idea
only, and it's more to verify the reason still (after it failed with
SG method...).

Thanks,
Jarek P.
