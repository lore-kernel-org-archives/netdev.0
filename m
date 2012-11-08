From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 0/2] Fix CDC_EEM with 802.1Q VLAN and 1500 MTU
Date: Thu, 8 Nov 2012 15:37:36 +0200
Message-ID: <20121108133736.GA19533@arwen.pp.htv.fi>
References: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
 <20121107.212752.1709967292920700431.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Cc: <iancoolidge@gmail.com>, <gregkh@linuxfoundation.org>,
	<balbi@ti.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53600 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193Ab2KHNnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 08:43:47 -0500
Content-Disposition: inline
In-Reply-To: <20121107.212752.1709967292920700431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Nov 07, 2012 at 09:27:52PM -0500, David Miller wrote:
> From: Ian Coolidge <iancoolidge@gmail.com>
> Date: Wed,  7 Nov 2012 16:39:17 -0800
>=20
> > cdc_eem USB host driver and gadget driver both are broken in 1500 MTU
> > case while using 802.1Q VLANs. In both cases, this is due to the
> > assumption of standard Ethernet frame length.
> >=20
> > v2: rebase against Dave Miller's 'net/master' tree
> >=20
> > Ian Coolidge (2):
> >   usb: gadget: g_ether: fix frame size check for 802.1Q
> >   net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs
>=20
> Applied, thanks.

did you take both ? I'd rather you waited for my Ack for anything under
drivers/usb/gadget/ so we avoid conflicts later.

cheers

--=20
balbi

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQm7WgAAoJEIaOsuA1yqREDO8QAJuaN5nEKv0abMGX3DO2MmLT
84Wcq4BJzY1r3YHaUELTw9GQQqjSQdMKq31FHVQNlr1TJOjOMNRqgLJyENpyP41m
Lsm957aduugErzRZ10copAXzs4n8NdrK2slAVkJ4msC4N7ccO42NoTcnS+gxSHpU
KYI9asIyEtOwjEJN+SsPgfr5+E/RewsYQ/jFzqTm8izw1I1HnHVDW5v1lVq0co/R
HSOtkWkXr0PU7o4sRrSrOdU6rxZ6OqCNd+C2lSH+lOL9uK4bEveLswnXVlQq+Ql+
wkmhQVsx8Ebsp+b0NzoGUUTGguQnChPf5E/wklrNlKyKZsP6nlUF2pb4Dyky7QLW
PuYn8uIeWdZTPR7nfaAmKQfG3z4RyCrLg8NcJpuLhiU1U5Nd0eAUmJn2cOywpe/c
wmIosVUx4RKF7waj4VW0IiOIzFJ8Ltlr+QfxTt6ov5/ntCxrMibaMObWpgQ2tOpW
3v5owYs64ypqnyPyoyJZSaBWEknSB5v5F6SFC7KF8B0dQjs+OkWqsXzmS2vegw7y
L5B0EO1yhISyPwbnzncvpufKuslTqKomf99D8UOJ7S9QqnFSpIZJZUlfTGuQkaDI
YO3+t0Xx6ebjs/J+AMfWi9bXQtYQYax7CCnQJmet3LHRzIFrYG6+WlX9qWGEjVSW
sUdy+0iCfoKOwxMTaHaD
=iN/I
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
