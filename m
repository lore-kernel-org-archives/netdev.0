From: Felipe Balbi <balbi@ti.com>
Subject: Re: [patch-net-next v2 3/3] net: ethernet: cpsw: don't requests IRQs
 we don't use
Date: Thu, 15 Jan 2015 19:28:52 -0600
Message-ID: <20150116012852.GA3115@saruman>
References: <1421254729-10602-3-git-send-email-balbi@ti.com>
 <54B770FC.6060003@ti.com>
 <20150115152053.GA16409@saruman>
 <20150115.181615.498992970722065060.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Cc: <balbi@ti.com>, <mugunthanvnm@ti.com>, <tony@atomide.com>,
	<linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60164 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871AbbAPB3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 20:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20150115.181615.498992970722065060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 15, 2015 at 06:16:15PM -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Thu, 15 Jan 2015 09:20:53 -0600
>=20
> > On Thu, Jan 15, 2015 at 01:19:16PM +0530, Mugunthan V N wrote:
> >> On Wednesday 14 January 2015 10:28 PM, Felipe Balbi wrote:
> >> > CPSW never uses RX_THRESHOLD or MISC interrupts. In
> >> > fact, they are always kept masked in their appropriate
> >> > IRQ Enable register.
> >> >=20
> >> > Instead of allocating an IRQ that never fires, it's best
> >> > to remove that code altogether and let future patches
> >> > implement it if anybody needs those.
> >> >=20
> >> > Signed-off-by: Felipe Balbi <balbi@ti.com>
> >>=20
> >> Instead of introducing dummy ISR in previous patch and then removing in
> >> this patch, both can be squashed into a single patch.
> >=20
> > sure they can. I decided to split to ease review and to make sure only
> > one thing happens in a single patch.
>=20
> Indeed, I agree that adding something as a placeholder that just gets
> immediately removed should be avoided unless it is extremely difficult
> to do so.

what does this mean ? you prefer both patches to be combined ?

--=20
balbi

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUuGlUAAoJEIaOsuA1yqREEB0P/RezNPTcHxm/FU+CnzlAII9Y
ZJTZ8Uck+6ardLCdd/O0PwlzFjYOTzNNnF1UfsnE1ngsaeYMu06kCyFJKrqwPbGK
eAzIpXhsqr1YKrO7Y3sGEIxdnsvL0E/OwuUJnBCSa6IligaaFkgCgjj2xFETcbal
QwGHUoUYtG4nDcXSttaEJH/Qw8w8ftUZeXYG8DZrQZ5t/WNjiZmfzZtHGY9f/BwI
Ue1DmssivLOIPiZ1BaJQglCJ0khlwnDuLEcVms51048ONPEU2QjGOs+0VYtYFNuX
YeIMwTrOMSEaMwCrT4N+AYsDdI3DNeE517ftMQtw+Qh40CWywNy55pnNNUID4x5y
I0iRSRpExOcTJq2i/8GvvpSFV3sXof8Gg3L1hGFfkdGKb3dXcKS/Bjg+KfDMyP9M
AKxTaB8lKEVf5G7wUzm+SYytnrfaTHbGMEBu9GGIy/s7O5IOXA3cAyZjmDWCDOEP
6y9aHQndwdiC0W9K7a0xTYSO6mdyn3zC/isoJ5nyp6FRCEWd61kPRfSyiMjs+R5M
f5zUIjkEbCKoivbIqzdXdI2wXkrKSPY8t1ytnV363lVRfm3QNWp2fS0qfzNX/XpL
EipxC7HpZy1LhjyAspUDnZB5hPsxJGOOalK2UeiJPdrSOx6b69gbMbw8A8y10HFT
WRbVvhpVGDj78D8WMZXP
=So4x
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
