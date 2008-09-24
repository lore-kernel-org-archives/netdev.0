From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 09:20:10 +0300
Message-ID: <48D9DC1A.10903@iki.fi>
References: <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au> <48D9CCA3.2040500@iki.fi> <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:3568 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbYIXGUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 02:20:16 -0400
Received: by nf-out-0910.google.com with SMTP id d3so855483nfc.21
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 23:20:14 -0700 (PDT)
In-Reply-To: <20080924061349.GA6679@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 24, 2008 at 09:04:30AM +0300, Timo Ter=E4s wrote:
>> Or at least add a comment to the dumping function to say that
>> we have struct xfrm_state, but in matter of fact it can be
>> also struct xfrm_state_walk pointer with displacement, so we
>> better check km.state first.
>=20
> Which is exactly what we do.  The first thing we check in the
> loop is km.state.  I really don't see your problem.

Yes. I'm not complaining that the code does not work.

Just saying that the code easily misleads the reader. And in
this kind of non-obvious places we should have some comments.
Or make the code more readable by adding the intermediate struct.

Cheers,
  Timo
