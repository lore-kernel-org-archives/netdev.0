From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Mon, 11 Feb 2013 18:40:56 +1100
Message-ID: <20130211184056.9a128947490514408c33b3ae@canb.auug.org.au>
References: <20130211133350.5f510bbb28759960a19a98af@canb.auug.org.au>
	<1360551527.2028.10.camel@joe-AO722>
	<1360565274.12803.45.camel@cumari.coelho.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__11_Feb_2013_18_40_56_+1100_o_mYMsAByh/4=fxi"
Cc: Joe Perches <joe@perches.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Luciano Coelho <coelho@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:37866 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab3BKHlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 02:41:11 -0500
In-Reply-To: <1360565274.12803.45.camel@cumari.coelho.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__11_Feb_2013_18_40_56_+1100_o_mYMsAByh/4=fxi
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 11 Feb 2013 08:47:54 +0200 Luciano Coelho <coelho@ti.com> wrote:
>
> On Sun, 2013-02-10 at 18:58 -0800, Joe Perches wrote:
> > On Mon, 2013-02-11 at 13:33 +1100, Stephen Rothwell wrote:
> > >=20
> > > Today's linux-next merge of the wireless-next tree got conflicts in
> > > drivers/net/wireless/ti/wlcore/sdio.c and
> > > drivers/net/wireless/ti/wlcore/spi.c between commit 0d2e7a5c6080
> > > ("wireless: Remove unnecessary alloc/OOM messages, alloc cleanups") f=
rom
> > > the net-next tree and commit afb43e6d88e5 ("wlcore: remove if_ops from
> > > platform_data") from the wireless-next tree.
> > >=20
> > > I fixed it up (see below) and can carry the fix as necessary (no acti=
on
> > > is required).
>=20
> The fix up looks good.  Thanks!
>=20
> > Thanks Stephen.
> >=20
> > Can you remove just the dev_err below too please.
> >=20
> > +       pdev_data =3D kzalloc(sizeof(*pdev_data), GFP_KERNEL);
> > +       if (!pdev_data) {
> > +               dev_err(&func->dev, "can't allocate platdev_data\n");
> > +               goto out;
> > +       }
>=20
> Yes, and there's also another one in
> drivers/net/wireless/ti/wlcore/spi.c:
>=20
> +       pdev_data =3D kzalloc(sizeof(*pdev_data), GFP_KERNEL);
> +       if (!pdev_data) {
> +               dev_err(&spi->dev, "can't allocate platdev_data\n");
> +               goto out;
> +       }

I presume that there is no harm in actually fixing these extra ones
directly in the wireless-next tree, right?  (hint, John, hint :-))

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__11_Feb_2013_18_40_56_+1100_o_mYMsAByh/4=fxi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRGKCIAAoJEECxmPOUX5FEWgwQAKaFRZYUp7LoFIBfVGvChgv7
t/L6gu84EoPd7za6z7Kxqch9lIDMXviLIFCJ6gpoc2TDT+o1F5Kx5SBuQzjVRqfu
Uk+xDUHOF82H/XXfd43el3pZwrw2grYfE9oUPns62y/FtEMS1obEU34Q0KHb60UU
F2srkX4K5WMsoT6krqz8+1xadTxC1T/SpM3VFywXxXQB5X1zB8FO57b3QzEf2prj
CNHZdV+bKj0Ex3zXQw57nGvKSb3yCsgdN/g2grzftlWdi0Lkbd6A7rmCwHi0O8Z2
XhvIGF7KOgXx3OQkUS/BF3GAIlw2x6Io9UNCSlml81K8pk3ISz48VIivScDzeQ6c
Nhyf+99+9/4L5wUtranpG7W0U+OV7jFi00l8s/+0jB6JJu0s9P2PjeBYUdRrHg/D
QEpEXtesfbveyZfxw9tmxA0yjp8S60FJyZN5VDw2Nmll71pjsPn9GWNEmTL6E8Pp
aNHvKmTBj8ub7iLHrAPMwb/kA64fFXqtb1lGFy3o9+lL8W7eSyARQJVm84PfQyIz
m6kDYUp7goAekO8T/UuukSnUjrLzbJaqYyHvgvg1n6N486ds8ouaLWdT/FgfICQw
gLdpxePskKXhSfu0CGUcjgnPC4DenGUiKPqst27J7J8MIgPyTcUO5AcCsoGgNRch
HnPTEwHlbm1QF0QcW7eF
=hAUx
-----END PGP SIGNATURE-----

--Signature=_Mon__11_Feb_2013_18_40_56_+1100_o_mYMsAByh/4=fxi--
