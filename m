From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: Samsung sxgbe driver - Kconfig issue
Date: Fri, 28 Mar 2014 17:20:25 -0400
Message-ID: <19617.1396041625@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1396041625_2170P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Siva Reddy Kallam <siva.kallam@samsung.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:34316 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbaC1VVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:21:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1396041625_2170P
Content-Type: text/plain; charset=us-ascii

commit 1edb9ca69e8a7988900fc0283e10550b5592164d
Author: Siva Reddy <siva.kallam@samsung.com>
Date:   Tue Mar 25 12:10:54 2014 -0700

    net: sxgbe: add basic framework for Samsung 10Gb ethernet driver

    This patch adds support for Samsung 10Gb ethernet driver(sxgbe).


This commit added the following in the Kconfig file:

config NET_VENDOR_SAMSUNG
        bool "Samsung Ethernet device"
        default y
        ---help---
          This is the driver for the SXGBE 10G Ethernet IP block found on Samsung
          platforms.

Please redo this to match the style of other NET_VENDOR_FOO, and make clear
that it only selects a submenu.  For instance, drivers/net/ethernet/qlogic/Kconfig
says:

config NET_VENDOR_QLOGIC
        bool "QLogic devices"
        default y
        depends on PCI
        ---help---
          If you have a network (Ethernet) card belonging to this class, say Y
          and read the Ethernet-HOWTO, available from
          <http://www.tldp.org/docs.html#howto>.

          Note that the answer to this question doesn't directly affect the
          kernel: saying N will just cause the configurator to skip all
          the questions about QLogic cards. If you say Y, you will be asked for
          your specific card in the following questions.

if NET_VENDOR_QLOGIC




--==_Exmh_1396041625_2170P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUzXnmQdmEQWDXROgAQJnQQ//a+SUvRfAFVCsxBkFI+snoWUVA3W8weIS
wmemK1eHdYlF8h16YFpV+nh9ZrozEDfygMb7r3RhUtIcYkbt0m7qKTjqCZCYWC9z
PFhAYQ+no5Lue6uS04tqfYPDZDRI8fpXCDGHwtAxfoVbPoiLB6SZbfleUohTFMiP
UwFJ/nII5JSyqwcFgUI2ph9UCq9m0i2uYs5YkS49zSfmqGoWtnYG/7D3FkUgvoM8
R34aSamoDjsl/MflFJadydzWsdrEQbt4uf2/GinPztl5afzfLt1Tf89BXAuRkPoQ
zF4KHpoIZIotEslkfPdBFSukBs9dvKDjOHO9jRMUUyPOmJi4UxbcUjik5QpfglSy
Ibfoyvm+ihyrp33Y8sgS+qDfxZUFWFMv3SkjGuYoEOfBRPCCrvW9s5xrCFFV21Qb
LD5FuJpAhsvIyLJeCqoGrlA0lSQs3Yjtsk2OJYX0HyGF7Th78ezLFrMkYij4KQI0
YnkB0THWmXsqS2X6jmpfRHRiGdIV2gtBCPbRwpt5HMcsMnB/1KRPu6+ZB+Mi3532
xku+KA8qXg9uJ13t8MXk9Sa/n/f8HQBUcTS5I4/b/iaynhvgUPeZgRIO6ozQYNeU
XQqvvA8J3v93QwZcP5X5+poHVuF5ViEG38xJqInVOvV7hy9Dd6PkMptBqW8PPxaQ
Yf+gjuYLfP0=
=aoRo
-----END PGP SIGNATURE-----

--==_Exmh_1396041625_2170P--
