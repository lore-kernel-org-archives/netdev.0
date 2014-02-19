From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipcomp: Convert struct xt_ipcomp spis into
 16bits
Date: Wed, 19 Feb 2014 11:14:03 +0100
Message-ID: <20140219101403.GA9160@localhost>
References: <1390011374-21760-1-git-send-email-fan.du@windriver.com>
 <20140118122437.GA4309@localhost>
 <52DC821E.3000309@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42892 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbaBSKON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 05:14:13 -0500
Content-Disposition: inline
In-Reply-To: <52DC821E.3000309@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 20, 2014 at 09:55:42AM +0800, Fan Du wrote:
> On 2014=E5=B9=B401=E6=9C=8818=E6=97=A5 20:24, Pablo Neira Ayuso wrote=
:
> >Didn't you find any way to fix this without change the layout of
> >xt_ipcomp?
>=20
> My bad for not catching this in the initial ipcomp version.
> It would be easier to just use ntohs here to ease sparse checking.
>=20
>=20
> From dbf796e63d600256fd40000669b83227ddccebc4 Mon Sep 17 00:00:00 200=
1
> From: Fan Du <fan.du@windriver.com>
> Date: Mon, 20 Jan 2014 09:42:12 +0800
> Subject: [PATCHv2 net-next] ipcomp: Use ntohs to ease sparse warning
>=20
> 0-DAY kernel build testing backend reported:
>=20
> sparse warnings: (new ones prefixed by >>)
>=20
> >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: restricted __be16 degr=
ades to integer
> >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: cast to restricted __b=
e32
>=20
> Fix this by using ntohs without shifting.
>=20
> Tested with: make C=3D1 CF=3D-D__CHECK_ENDIAN__

Applied to nf-next, thanks.
