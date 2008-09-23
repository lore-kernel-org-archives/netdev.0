From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 21:32:34 +0800
Message-ID: <20080923133234.GA30370@gondor.apana.org.au>
References: <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57715 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750806AbYIWNcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 09:32:47 -0400
Content-Disposition: inline
In-Reply-To: <48D8EF5E.1060500@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:30:06PM +0300, Timo Ter=E4s wrote:
>
> I have no strong opinion either way. So what ever you want, I'm
> happy to provide a patch for.

Let's just leave it as it is for now.

> > What about xfrm_cfg_mutex?
>=20
> It's used only in xfrm_state_gc_task. xfrm_state_walk_{init,done}
> touch xfrm_state_walks list without locking properly. At least in
> the version I'm looking (=3D net-next-2.6 via git web interface).

Their callers should be holding it.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
