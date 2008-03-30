From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for March 29
Date: Sun, 30 Mar 2008 13:55:02 +1100
Message-ID: <20080330135502.ee27f8a4.sfr@canb.auug.org.au>
References: <20080329223354.304e2722.sfr@canb.auug.org.au>
	<20080329191255.7312e036@hskinnemo-gx620.norway.atmel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__30_Mar_2008_13_55_02_+1100_lge9CGjU60uTTxuw"
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org
To: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20080329191255.7312e036@hskinnemo-gx620.norway.atmel.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sun__30_Mar_2008_13_55_02_+1100_lge9CGjU60uTTxuw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Haavard,

On Sat, 29 Mar 2008 19:12:55 +0100 Haavard Skinnemoen <haavard.skinnemoen@a=
tmel.com> wrote:
>
> I see both avr32 builds currently fail, but for different
> reasons...none of which is avr32-specific as far as I can tell.
>=20
> defconfig fails with
>=20
> drivers/ata/libata-core.c:127: error: 'ata_pci_default_filter' undeclared=
 here (not in a function)
>=20
> which seems to be due to CONFIG_ATA && !CONFIG_PCI
>=20
> allnoconfig fails with
>=20
> include/linux/netdevice.h:843: error: implicit declaration of function 'd=
ev_net'
>=20
> which seems to be because the definition of dev_net is inside #ifdef
> CONFIG_NET, while next_net_device, which calls it, is not.

Thanks for tracking these down.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sun__30_Mar_2008_13_55_02_+1100_lge9CGjU60uTTxuw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFH7wEQTgG2atn1QN8RAitvAKCXVKAM/HHlTiUOCfZjflNSKzmQSwCfYHZy
RsQXX1qG5JSnx0lYZxfZ7qQ=
=mrWe
-----END PGP SIGNATURE-----

--Signature=_Sun__30_Mar_2008_13_55_02_+1100_lge9CGjU60uTTxuw--
