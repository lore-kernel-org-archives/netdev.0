From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 20:49:19 +0800
Message-ID: <20100320124919.GA2243@gondor.apana.org.au>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi> <20100320123247.GB1930@gondor.apana.org.au> <4BA4C29A.8000806@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35798 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751849Ab0CTMtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:49:23 -0400
Content-Disposition: inline
In-Reply-To: <4BA4C29A.8000806@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 02:42:02PM +0200, Timo Ter=E4s wrote:
>
> But even if we have the gc_thresh back to 1024 or similar size,
> it is still a good thing to do some basic gc on xfrm bundles so
> that the underlaying rtable dst's can be freed before they end up
> in the dst core list.

But I'm not sure if a timer-based one really makes sense though.

If you're worried about stale entries preventing IPv4/IPv6 rt
entries from being collected, perhaps we should invoke the xfrm
GC process from the IPv4/IPv6 GC function?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
