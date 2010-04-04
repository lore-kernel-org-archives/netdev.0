From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 16:35:56 +0800
Message-ID: <20100404083556.GA10223@gondor.apana.org.au>
References: <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au> <4BB828B1.5090109@iki.fi> <20100404055830.GA9484@gondor.apana.org.au> <4BB82C90.70809@iki.fi> <20100404061941.GA9642@gondor.apana.org.au> <4BB8319B.3040209@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751904Ab0DDIf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 04:35:59 -0400
Content-Disposition: inline
In-Reply-To: <4BB8319B.3040209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 09:28:43AM +0300, Timo Ter=E4s wrote:
>
> No. The flow cache flush removal does not prevent bundle deletion.
> The flow cache flush is in current code *after* deleting the bundles
> from the policy. Freeing bundles and flushing cache are completely
> two separate things in current code. Only in 2/4 the bundle deletion
> becomes dependent on flow cache flush.

Ah yes I confused myself.  The problem I thought would occur
doesn't because 1/4 doesn't put the bundles in the flow cache
yet.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
