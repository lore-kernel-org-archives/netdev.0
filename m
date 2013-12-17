From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: make local functions static and remove
 dead code
Date: Mon, 16 Dec 2013 16:52:00 -0800
Message-ID: <1387241520.2330.4.camel@jtkirshe-mobl>
References: <20131212120916.688140d9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FDlP2A8RA86YdD9cMTWg"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25020 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab3LQAwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 19:52:02 -0500
In-Reply-To: <20131212120916.688140d9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FDlP2A8RA86YdD9cMTWg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-12-12 at 12:09 -0800, Stephen Hemminger wrote:
> Make local functions static, and remove unused
> e1000_write_sfp_data_byte.
>=20
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c |    6 +++---
>  drivers/net/ethernet/intel/igb/e1000_i210.c  |   18
> +++++++++---------
>  drivers/net/ethernet/intel/igb/e1000_i210.h  |    9 ---------
>  drivers/net/ethernet/intel/igb/e1000_phy.c   |    2 +-
>  drivers/net/ethernet/intel/igb/e1000_phy.h   |    1 -
>  drivers/net/ethernet/intel/igb/igb.h         |    2 --
>  drivers/net/ethernet/intel/igb/igb_ptp.c     |    6 ++++--
>  7 files changed, 17 insertions(+), 27 deletions(-)

Did you compile test this patch?  I am guessing no because we got the
following compile errors:
 drivers/net/ethernet/intel/igb/e1000_82575.c:2723: error: static
declaration of
 =C3=A2igb_get_thermal_sensor_data_generic=C3=A2 follows non-static declara=
tion
 drivers/net/ethernet/intel/igb/e1000_82575.h:270: note: previous
declaration
 of =C3=A2igb_get_thermal_sensor_data_generic=C3=A2 was here
 drivers/net/ethernet/intel/igb/e1000_82575.c:2777: error: static
declaration of
 =C3=A2igb_init_thermal_sensor_thresh_generic=C3=A2 follows non-static decl=
aration
 drivers/net/ethernet/intel/igb/e1000_82575.h:269: note: previous
declaration
 of =C3=A2igb_init_thermal_sensor_thresh_generic=C3=A2 was here
 make[5]: *** [drivers/net/ethernet/intel/igb/e1000_82575.o] Error 1
 make[5]: *** Waiting for unfinished jobs....
 make[4]: *** [drivers/net/ethernet/intel/igb] Error 2
 make[4]: *** Waiting for unfinished jobs....
 make[3]: *** [drivers/net/ethernet/intel] Error 2
 make[2]: *** [drivers/net/ethernet] Error 2
 make[1]: *** [drivers/net] Error 2
 make: *** [drivers] Error 2

I will work on a v2 to fix up these compiling issues.

--=-FDlP2A8RA86YdD9cMTWg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSr6AwAAoJEOVv75VaS+3OLVQP/2gAVhTbtSmuLnaMDAnRNhyu
rzvmhkOKaYoR0UY9jBL5v/gvu3E+HGj2A/RlQ8xzv12BT0FZyW5Ddfe+BA5N4CHa
YH/DrWxAmblRh7CXWhyYm6Yfd3ANR2H074rv5tENiWrs24hGYXKlQ7joA/dXcw8I
fSmXUNXVfB89c+xUJJFSl3IvqO1VksPL4OfBS52uQaT8tGrq6JaUmzYuwUNfdqBh
OsFLhgpar9I/9/OZljy/bY3Wo+9QqzU88WgOi2NYK4GJcSGrpGc1t2/OnG2lmD7F
XKq3kALhUJTur1DODrwhU9jOjq3puiXNhJUTHwhQRD1+3kytsiNkCcN6OuvVi+SK
yB35nGlKTfyMXLgXaB9yWbUucbITTRPVdNAUQNk0O4gBJ2pg6cljyFqCgMwgxBZS
cIo4Gw85l9YnWjzOKIj+p7bFR1iCbzfHD02hVlRUJhWIefygTxKOGcZxierO+qDq
SOqZQzx61AXi/n4bz89d0Kyy4+OBYK57Ajdcwiqx3yd77DpIPWEc9SoehTDqQYF7
6Xxp9cNczpgs3n4DP/ywXH5R+PVk5dVhqWHSXSxCGKPR9sLUY/8SUe6QV2Rll6ma
ndrax1MwTT7ajHljD8snRAHIV8LGx0mIvyd0ZEiZS2rGBmH6wJGZvs4/WWThLSz3
lAQBU/m/mk5Chfiwv66w
=IvSs
-----END PGP SIGNATURE-----

--=-FDlP2A8RA86YdD9cMTWg--
