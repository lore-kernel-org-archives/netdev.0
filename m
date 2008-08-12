From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Tue, 12 Aug 2008 08:50:33 +0800
Message-ID: <20080812005033.GA18547@gondor.apana.org.au>
References: <48A03EF9.9090602@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Brice Goglin <brice@myri.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33513 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753037AbYHLAuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:50:35 -0400
Content-Disposition: inline
In-Reply-To: <48A03EF9.9090602@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 09:30:33AM -0400, Andrew Gallatin wrote:
>
> For lro_receive_frags() based LRO, it would be ideal to locate the
> header in place in the frag via the mac_hdr argument to the
> get_frag_header() callback.  Eg, I'm hoping that neither the driver
> nor the LRO module will need to allocate extra memory per frame and
> copy the headers to it in the common case when forwarding is
> not enabled.  That would add quite a bit of overhead.

You don't have to save the whole thing, just save enough so we
can easily/exactly reconstruct it on output, i.e., save the lengths.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
