From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] xfrm_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 23:24:15 +0800
Message-ID: <20071126152415.GE28022@gondor.apana.org.au>
References: <007c01c8300b$176975a0$9c94fea9@jason> <474A8D97.2030808@trash.net> <000301c83016$774dcba0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Patrick McHardy' <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3802 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750914AbXKZPYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:24:23 -0500
Content-Disposition: inline
In-Reply-To: <000301c83016$774dcba0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 10:23:51AM +0000, Joonwoo Park wrote:
> 2007/11/26, Patrick McHardy <kaber@trash.net>:
> > How about also switching vmalloc/get_free_pages to GFP_ZERO
> > and getting rid of the memset entirely while you're at it?
> > 
> 
> xfrm_hash: kmalloc + memset conversion to kzalloc
> fix to avoid memset entirely.

Patch applied.  Thanks everyone!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
