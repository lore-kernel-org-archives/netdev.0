From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 03/14] ethtool: Expand documentation of struct
 ethtool_wol
Date: Wed, 12 Feb 2014 22:14:07 +0000
Message-ID: <1392243247.15615.7.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-G6GX65SV3/U4cx0v4g1O"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52780 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754251AbaBLWOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:15 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-G6GX65SV3/U4cx0v4g1O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cc523cb..15a42de 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -186,12 +186,21 @@ struct ethtool_drvinfo {
 };
=20
 #define SOPASS_MAX	6
-/* wake-on-lan settings */
+
+/**
+ * struct ethtool_wolinfo - Wake-On-Lan configuration
+ * @cmd: Command number =3D %ETHTOOL_GWOL or %ETHTOOL_SWOL
+ * @supported: Bitmask of %WAKE_* flags for supported Wake-On-Lan modes.
+ *	Read-only.
+ * @wolopts: Bitmask of %WAKE_* flags for enabled Wake-On-Lan modes.
+ * @sopass: SecureOn(tm) password; meaningful only if %WAKE_MAGICSECURE
+ *	is set in @wolopts.
+ */
 struct ethtool_wolinfo {
 	__u32	cmd;
 	__u32	supported;
 	__u32	wolopts;
-	__u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
+	__u8	sopass[SOPASS_MAX];
 };
=20
 /* for passing single values */


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-G6GX65SV3/U4cx0v4g1O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyMOe/yOyVhhEJAQo1NA/9FVCcD5NjXBnoAYpWj3iSjXP/pMCX6CVT
HMv9JitiZoxiyLURaUZuKVOsu+/2Yg1hL///OEehT7vPfG5EDX6OErzCrwwAblf/
B25i0BoZZfVQeqnbCFBu4HtYRnP99eWAaU6LHeijOAVuXDA+huhwzMmYXFswBmY7
/aufLPYtxNg+/wPPUPspBp4zTOgiXO9dnW4Dc/dp3PHS2PpI6OQo1LkLx9Q8kF3s
JKNpYytwHwzfwwbLR+CLUFvG0SF1CnjIxbHmQykfbfhMlc5uprfg6yeZT++twyK1
UUKMpnWbWT+IvdrjewFoNaw6cjhlEM0bytaZ1JsFNj4pEc5Oj4nup55jct9hzFT0
XuzV/Bo5gIFUiXBzs3ivOwSvLJw4PFcbFeSErZZdidO8eVkjeb2UpWuphHaPRP/Q
2hm603VCM2QWdTTz2JV4MbZdQg/1QwePzENHb/29Y9Fdm90HopZLybJ4XKYW/SR7
XDnsRcCNChl4Mrqjcc/qkGZbivqM32ojWJKyIpNm8fhG9f3LcySK26KOXVmCNWp5
VtWgtxrgOmsE0HHarbf2FGDnGtukRz2r3k+fmkWWUX4fWCC3zhNu8dKwEUueNzJ9
b9kJGcFy2XTmiUgx/76nyfFocKMrD1lW4VirdQTRjzP6hUAWthpiigqrNHFJFiwi
zhOUd2taIwA=
=1nV+
-----END PGP SIGNATURE-----

--=-G6GX65SV3/U4cx0v4g1O--
