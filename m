From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 08:43:00 +0800
Message-ID: <20100331004259.GA9977@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <4BB2044B.5080704@iki.fi> <20100330142914.GA6840@gondor.apana.org.au> <4BB21A85.2030203@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:54010 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755594Ab0CaAnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 20:43:04 -0400
Content-Disposition: inline
In-Reply-To: <4BB21A85.2030203@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 06:36:37PM +0300, Timo Ter=E4s wrote:
>
> I only added it because it's non-trivial to figure out if there's
> any code path that could race. It's a great help for reader of the
> code to see that it's correct even if it's not strictly needed.

No that's bad because you're misleading people into thinking
something that isn't allowed can happen.  It's much better to
add a comment instead.

> I will also include a patch to fix the missing 'dir' check in
> xfrm_user.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
