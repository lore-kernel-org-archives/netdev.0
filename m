From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Fri, 18 Jan 2008 08:34:48 +1100
Message-ID: <20080117213448.GA14716@gondor.apana.org.au>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi> <1200573750.4508.29.camel@localhost> <20080117125016.GA9820@gondor.apana.org.au> <478F58A2.6030209@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51801 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752483AbYAQVez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 16:34:55 -0500
Content-Disposition: inline
In-Reply-To: <478F58A2.6030209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2008 at 03:31:14PM +0200, Timo Ter=E4s wrote:
>=20
> I guess the idea was that application should know about the SAs it
> created. Though a SA dump needs to be done if you want to check
> for existing entries (created by other processes, or if you are
> recovering from a crash).

That's what SADB_GET is for.  In any case KMs cannot coexist so this
is pointless.  After a crash you should simply flush all states and
policies.

> SPD dumping is still a must if you want to work nicely with kernel.

No it isn't.  Look at how Openswan does it.  No dumping anywhere at all=
=2E

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
