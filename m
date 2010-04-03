From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 3 Apr 2010 23:53:53 +0800
Message-ID: <20100403155353.GA5618@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56665 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753374Ab0DCPx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 11:53:56 -0400
Content-Disposition: inline
In-Reply-To: <4BB74FF8.2020303@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 03, 2010 at 05:26:00PM +0300, Timo Ter=E4s wrote:
>
> Why would this block? The device down hook calls flow cache
> flush. On flush all bundles with non-up devices get pruned
> immediately (via stale_bundle check).

Perhaps I missed something in your patch, but the flush that
we currently perform is limited to the bundles from hashed policies.
So if a policy has just recently been removed, then its bundles
won't be flushed.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
