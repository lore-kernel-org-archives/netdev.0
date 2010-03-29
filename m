From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 20:25:47 +0800
Message-ID: <20100329122547.GA24666@gondor.apana.org.au>
References: <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi> <20100329115701.GA24367@gondor.apana.org.au> <4BB0970E.7060405@iki.fi> <20100329121124.GA24470@gondor.apana.org.au> <4BB09AFD.4050304@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:50040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752761Ab0C2MZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:25:54 -0400
Content-Disposition: inline
In-Reply-To: <4BB09AFD.4050304@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 03:20:13PM +0300, Timo Ter=E4s wrote:
>
> But as noted few mails ago, it's not necessary. So I'll just go
> ahead and remove all locking from the read side, and move the
> xfrm_policy_kill to use plain write.

No you can't make it a plain write in xfrm_policy_kill.  The same
policy may be killed simultaneously, by the timer and user action.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
