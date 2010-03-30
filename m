From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Tue, 30 Mar 2010 22:29:14 +0800
Message-ID: <20100330142914.GA6840@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <4BB2044B.5080704@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42726 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755765Ab0C3O3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 10:29:18 -0400
Content-Disposition: inline
In-Reply-To: <4BB2044B.5080704@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 05:01:47PM +0300, Timo Ter=E4s wrote:
>
> Since the exported function xfrm_policy_byid() can result in deletion
> of socket policy, it's safer to leave this change in. This is can be
> even triggered via xfrm_user since it does not check 'dir' for the
> policy expired message it handles. Any custom module could do similar
> harm.

That's a bug.  Socket policies should never be deleted by anyone
other than the socket owner through a setsockopt.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
