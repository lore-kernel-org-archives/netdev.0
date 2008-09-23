From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Mon, 22 Sep 2008 19:48:35 -0700 (PDT)
Message-ID: <20080922.194835.193693316.davem@davemloft.net>
References: <48D63E3A.90301@iki.fi>
	<48D66677.2040309@iki.fi>
	<20080922114256.GA27055@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754354AbYIWCsr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 22:48:47 -0400
In-Reply-To: <20080922114256.GA27055@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 22 Sep 2008 19:42:56 +0800

> ipsec: Fix xfrm_state_walk race
>=20
> As discovered by Timo Ter=E4s, the currently xfrm_state_walk scheme
> is racy because if a second dump finishes before the first, we
> may free xfrm states that the first dump would walk over later.
>=20
> This patch fixes this by storing the dumps in a list in order
> to calculate the correct completion counter which cures this
> problem.
>=20
> I've expanded netlink_cb in order to accomodate the extra state
> related to this.  It shouldn't be a big deal since netlink_cb
> is kmalloced for each dump and we're just increasing it by 4 or
> 8 bytes.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied to net-next-2.6
