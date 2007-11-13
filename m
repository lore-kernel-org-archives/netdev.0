From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Tue, 13 Nov 2007 22:41:58 +1100
Message-ID: <200711132241.59074.nickpiggin@yahoo.com.au>
References: <200711092336.56172.nickpiggin@yahoo.com.au> <200711101229.35822.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0711121144001.26936@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.mail.mud.yahoo.com ([209.191.85.220]:30068 "HELO
	smtp110.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754693AbXKNAE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 19:04:27 -0500
In-Reply-To: <Pine.LNX.4.64.0711121144001.26936@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 November 2007 06:44, Christoph Lameter wrote:
> On Sat, 10 Nov 2007, Nick Piggin wrote:
> > BTW. your size-2048 kmalloc cache is order-1 in the default setup,
> > wheras kmalloc(1024) or kmalloc(4096) will be order-0 allocations. And
> > SLAB also uses order-0 for size-2048. It would be nice if SLUB did the
> > same...
>
> You can try to see the effect that order 0 would have by booting with
>
> slub_max_order=0

Yeah, that didn't help much, but in general I think it would give
more consistent and reliable behaviour from slub.
