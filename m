From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 20 Jul 2012 12:01:18 +1000
Message-ID: <20120720120118.465056f267ab5c3ac5ea45c4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__20_Jul_2012_12_01_18_+1000_yc_XPQQFW=ZoDQyt"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Neuling <mikey@neuling.org>,
	Christian Riesch <christian.riesch@omicron.at>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__20_Jul_2012_12_01_18_+1000_yc_XPQQFW=ZoDQyt
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
pmac32_defconfig) failed like this:

ERROR: "phy_disconnect" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_stop" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_ethtool_gset" [drivers/net/usb/asix.ko] undefined!
ERROR: "mdiobus_unregister" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_start_aneg" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_print_status" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_start" [drivers/net/usb/asix.ko] undefined!
ERROR: "mdiobus_free" [drivers/net/usb/asix.ko] undefined!
ERROR: "mdiobus_register" [drivers/net/usb/asix.ko] undefined!
ERROR: "genphy_resume" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_connect" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_mii_ioctl" [drivers/net/usb/asix.ko] undefined!
ERROR: "phy_ethtool_sset" [drivers/net/usb/asix.ko] undefined!
ERROR: "mdiobus_alloc_size" [drivers/net/usb/asix.ko] undefined!

Caused by commit 16626b0cc3d5 ("asix: Add a new driver for the AX88172A")
and reverting that commit fixes the build.

Thanks to Mikey for reporting this porblem.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__20_Jul_2012_12_01_18_+1000_yc_XPQQFW=ZoDQyt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQCLvuAAoJEECxmPOUX5FEOH8P/180Jlo7BIX5dyA9xyM/smgT
b2TcowgexOejmuA3mTHaSdvDrMNESuS3EhQPeYREA8jKbp90kpfizjybiKc968vy
WiCh2cYO9jAphC7lihB/IC1Q2ffRg844+c4nJLFd8P6DT+LWMnzjpPfXekhaJNnJ
hmQvp3OrzPSF/2T/Uy4IW9Q04n7uoW+ttmQ7d+YT+JRfTQi9xhOrKU05UwEh/4Nq
KCUGzUO549u85JcHqFyGLhcLZC9ekHiVLmSYOoUH6+Y20m7ofcMg9Sczi8pTZelq
Hvm9maPATtLw+mRxjF6Z+NhGznoRooaorHdD/a3CrMtJ5oeZ76miSuE5euSUrjTr
m+Dwg8Fa1Jv8FgSBg4EsVYCONuHdwK8LcNosu30PJGB49B1Y8sdLa/LrmUSd3tWC
KOdg/L1BIeLmar5f93qnvHpN9frNcstNfaMHawBAWuhuItHr3GNOY1RFDIUdcXey
iSDM8kVep23wicqZXapyGSAgMw+H0Vqv/KooyYpWVYfKTxaYzWi+Dev7tcdKu5Zb
UftnTlEX+93tAhHR110fKtVzuqxfYPEyaMh52lwzMZGAfXcEyIVqxpzWQ8Em6Oxs
LU4dL4DU0H0ZHXHZBg9Jrl5FtEK/UnOiKnnY6HvlRD4lLnXyCQ5TzW67ACcGT8+Q
wYd3gz3PT2p9lBAKXBh0
=yz+h
-----END PGP SIGNATURE-----

--Signature=_Fri__20_Jul_2012_12_01_18_+1000_yc_XPQQFW=ZoDQyt--
