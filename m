From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: include route header_len in max_headroom
	calculation
Date: Sat, 20 Mar 2010 23:00:49 +0800
Message-ID: <20100320150049.GA2950@gondor.apana.org.au>
References: <1269088078-7343-1-git-send-email-timo.teras@iki.fi> <20100320123736.GC1930@gondor.apana.org.au> <4BA4C2ED.9090701@iki.fi> <4BA4E000.1030206@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33089 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752701Ab0CTPAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 11:00:55 -0400
Content-Disposition: inline
In-Reply-To: <4BA4E000.1030206@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 04:47:28PM +0200, Timo Ter=E4s wrote:
>
> Actually, isn't the above right?
>
> max_headroom is calculated with LL_RESERVED_SPACE of the tdev, which
> is the interface to which the gre packet is being sent to, not the
> gre interface. Thus, max_headroom won't include gre devices
> previous needed_headroom.

Indeed you're right.  Sorry for the confusion.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
