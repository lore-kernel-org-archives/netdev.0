From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] xfrm: cache bundles instead of policies for
	outgoing flows
Date: Tue, 6 Apr 2010 21:11:18 +0800
Message-ID: <20100406131117.GA24636@gondor.apana.org.au>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-3-git-send-email-timo.teras@iki.fi> <20100406124014.GA24412@gondor.apana.org.au> <4BBB2F31.7090806@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35512 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754256Ab0DFNLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 09:11:20 -0400
Content-Disposition: inline
In-Reply-To: <4BBB2F31.7090806@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 06, 2010 at 03:55:13PM +0300, Timo Ter=E4s wrote:
>
> Which also makes me think of another issue. The resolver does
> not get notice if the genid was outdated. So it might end up
> the old policies from bundle after xfrm_policy_insert(). I think
> we should explicitly call ops->delete() in flow_cache_lookup if
> the flow genid was outdated. (I remember actually doing this,
> but also removing it when I was hunting my the one hlist related
> corruption bug.)

Right, that makes sense.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
