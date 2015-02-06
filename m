From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: fix sparse warnings
Date: Thu, 05 Feb 2015 17:30:44 -0800
Message-ID: <1423186244.2589.89.camel@jtkirshe-mobl>
References: <1423146452-9379-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FnpGAGPnQXc4+J3GZEUF"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423146452-9379-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FnpGAGPnQXc4+J3GZEUF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-02-05 at 14:27 +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>=20
> this patch fixes following sparse warnings:
>=20
> ixgbe_x550.c:83:5: warning: symbol 'ixgbe_init_eeprom_params_X550' was
> not declared. Should it be static?
> ixgbe_x550.c:113:5: warning: symbol 'ixgbe_read_iosf_sb_reg_x550' was
> not declared. Should it be static?
> ixgbe_x550.c:161:5: warning: symbol 'ixgbe_read_ee_hostif_data_X550'
> was not declared. Should it be static?
> ixgbe_x550.c:196:5: warning: symbol 'ixgbe_read_ee_hostif_buffer_X550'
> was not declared. Should it be static?
> ixgbe_x550.c:334:5: warning: symbol 'ixgbe_calc_checksum_X550' was not
> declared. Should it be static?
> ixgbe_x550.c:410:5: warning: symbol 'ixgbe_calc_eeprom_checksum_X550'
> was not declared. Should it be static?
> ixgbe_x550.c:422:5: warning: symbol 'ixgbe_read_ee_hostif_X550' was
> not declared. Should it be static?
> ixgbe_x550.c:443:5: warning: symbol
> 'ixgbe_validate_eeprom_checksum_X550' was not declared. Should it be
> static?
> ixgbe_x550.c:492:5: warning: symbol 'ixgbe_write_ee_hostif_data_X550'
> was not declared. Should it be static?
> ixgbe_x550.c:520:5: warning: symbol 'ixgbe_write_ee_hostif_X550' was
> not declared. Should it be static?
> ixgbe_x550.c:540:5: warning: symbol 'ixgbe_update_flash_X550' was not
> declared. Should it be static?
> ixgbe_x550.c:563:5: warning: symbol
> 'ixgbe_update_eeprom_checksum_X550' was not declared. Should it be
> static?
> ixgbe_x550.c:603:5: warning: symbol
> 'ixgbe_write_ee_hostif_buffer_X550' was not declared. Should it be
> static?
> ixgbe_x550.c:633:6: warning: symbol 'ixgbe_init_mac_link_ops_X550em'
> was not declared. Should it be static?
> ixgbe_x550.c:650:5: warning: symbol 'ixgbe_setup_sfp_modules_X550em'
> was not declared. Should it be static?
> ixgbe_x550.c:706:5: warning: symbol
> 'ixgbe_get_link_capabilities_X550em' was not declared. Should it be
> static?
> ixgbe_x550.c:743:5: warning: symbol 'ixgbe_write_iosf_sb_reg_x550' was
> not declared. Should it be static?
> ixgbe_x550.c:907:5: warning: symbol 'ixgbe_setup_kx4_x550em' was not
> declared. Should it be static?
> ixgbe_x550.c:945:5: warning: symbol 'ixgbe_setup_kr_x550em' was not
> declared. Should it be static?
> ixgbe_x550.c:990:5: warning: symbol 'ixgbe_setup_internal_phy_x550em'
> was not declared. Should it be static?
> ixgbe_x550.c:1052:5: warning: symbol 'ixgbe_init_phy_ops_X550em' was
> not declared. Should it be static?
> ixgbe_x550.c:1105:23: warning: symbol 'ixgbe_get_media_type_X550em'
> was not declared. Should it be static?
> ixgbe_x550.c:1132:5: warning: symbol 'ixgbe_init_ext_t_x550em' was not
> declared. Should it be static?
> ixgbe_x550.c:1205:5: warning: symbol 'ixgbe_reset_hw_X550em' was not
> declared. Should it be static?
>=20
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>  Found this issue on linux-next (gcc  version 4.9.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 64
> ++++++++++++++-------------
>  1 file changed, 34 insertions(+), 30 deletions(-)

Don Skidmore already has a patch to resolve these warnings in my queue.
So I will be dropping this patch.

--=-FnpGAGPnQXc4+J3GZEUF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU1BlEAAoJEOVv75VaS+3OpMEP/A4bclr/I2Htiu+XPRC8ywiD
U64BGjReTK5JR8yhX9KqH3Bl3zlxMp6C/H9sXkfsiNRwR9c4jHaFAE05QxFGru2z
AaA0xSWqQ7F2SJMRhmB3kGqj3DPIKYipHl2PyuIMV/Y3mZu9xf9OxudMoJIC2KH2
cpWJfUM2jGBYrQFedFIix8SsMUXjwT/ew8mOSnwnXETjvoaN5tP2x21ImveVV0d9
LcllEtaVUp+ZX02jKqZi+DXQQzETvtzHZ83g47okJWnTm42x9/UUZZQOBnzrTk8r
dEKM6AhV9VtuOLGpt0+//FjvhHVNJ2U4xkGHh/TKj5xddLITZS8/kkD91dmyd9Kz
P6IeTC7By8NC4vFyKUipvgo+yITbKxq/7XihfQ/CiBjKtx3ZxQ5BVBpsiuHbhihD
LJOiTPpocG6gMrKNP3gEDCN713jB3qnBqBgoBt28LguRDSFljTNA9/8/xvRPf701
UV6fXO0Tc/1CO3sGBp6+fJTJCpsMFaKjHgDaYs85ke6CgS0C4TzWsWcavitax+rz
XslH8Lv1Cr8IRN9ipfL0P0R6P0dug2W9clQloPalU8Pp7RAvRTDGYC3FcujYkQE8
7HFtMYlrh4qW3zyWT6KzJTyCflI/TVC7PD4c7IdYE0DuGPVXH4g6X3ey/4wUUtjd
tH2t5FMozFfbq4bYMi6x
=tX4a
-----END PGP SIGNATURE-----

--=-FnpGAGPnQXc4+J3GZEUF--
