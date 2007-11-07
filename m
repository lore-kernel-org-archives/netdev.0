From: David Miller <davem@davemloft.net>
Subject: Re: Possible BUG on net/ipv4/ipcomp.c, line 358 (fwd)
Date: Wed, 07 Nov 2007 02:22:19 -0800 (PST)
Message-ID: <20071107.022219.176932535.davem@davemloft.net>
References: <Xine.LNX.4.64.0711070751530.27327@us.intercode.com.au>
	<20071107011124.GA29479@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jmorris@namei.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751673AbXKGKWT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 05:22:19 -0500
In-Reply-To: <20071107011124.GA29479@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 7 Nov 2007 09:11:24 +0800

> [IPSEC]: Fix crypto_alloc_comp error checking
>=20
> The function crypto_alloc_comp returns an errno instead of NULL
> to indicate error.  So it needs to be tested with IS_ERR.
>=20
> This is based on a patch by Vicen=E7 Beltran Querol.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and I'll queue this up for -stable too.

Thanks!
