From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 20:41:50 +1100
Message-ID: <20090122094150.GB14491@gondor.apana.org.au>
References: <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au> <49782EE4.2070809@iki.fi> <20090122085053.GA12806@gondor.apana.org.au> <49783B59.90208@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58930 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754555AbZAVJl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:41:56 -0500
Content-Disposition: inline
In-Reply-To: <49783B59.90208@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 11:24:41AM +0200, Timo Ter=E4s wrote:
>
> In DMVPN/GRE case, the NAT-OA from IPsec would not be used
> unless the NAT-OA is set on neighbour cache. This would not
> happen unless NHRP can authenticate it. In DMVPN case you need
> a valid certificate to give the ranom NAT-OA in any case. So
> if you lie about your NAT-OA I can just revoke you.

I don't see how NHRP authentication would help if the attacker
takes over someone else's address and causes packets for the
third party to go to it.

As to revoking the attacker's access, that's like saying "I'll
run an open telnet port but if you try to sniff my psasword I'll
revoke your access" :)

> Or do you have, other recommendations how to distinguish peers
> behind same public IP than NAT-OA? Maybe we add the certificate
> subject to xfrm state and neighbour cache. And use that?

Yes I think that is a much better solution for this.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
