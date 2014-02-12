From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 13/14] ethtool: Move kernel-doc comment next to
 struct ethtool_dump definition
Date: Wed, 12 Feb 2014 22:14:59 +0000
Message-ID: <1392243299.15615.17.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QwdJuZnsK8IegMLTQghV"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52817 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbaBLWPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:15:07 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QwdJuZnsK8IegMLTQghV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The kernel-doc script does not tolerate the macro definition in between.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 79be416..24418ac 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -920,9 +920,6 @@ struct ethtool_flash {
  * 	 for %ETHTOOL_GET_DUMP_FLAG command
  * @data: data collected for get dump data operation
  */
-
-#define ETH_FW_DUMP_DISABLE 0
-
 struct ethtool_dump {
 	__u32	cmd;
 	__u32	version;
@@ -931,6 +928,8 @@ struct ethtool_dump {
 	__u8	data[0];
 };
=20
+#define ETH_FW_DUMP_DISABLE 0
+
 /* for returning and changing feature sets */
=20
 /**


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-QwdJuZnsK8IegMLTQghV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyY+e/yOyVhhEJAQqathAAocsSLz8fTCjQFspLaPYzN2csmmkj0/1o
VMihgjXLbqSDOAeSFnPphViXryFdZPAqMtuoUqWllvzaOn9AwwQRrrQy0STSEB7j
PRMfJIL1Qtu8TIAKl1+sCV9xZirgYkMSzMMd8WPS+jmp1bBm0+yDW7vqkLPytVZs
7HSLbBLCbXHlBS7vGCK+G75hGwdXe+5t5HDWHkHfCN+AnttDCX+CA7ZPk+KeQiJQ
ZPi7LYb4OsHSLJ3LBEo5H4VWMLdSy3oSD4ke3ac08QsCWhCtgtoyFbf5VtDrsBzn
p4/eTFF4hJ0aMU3UMJjpHPsvRMGAfFXy26zAFO757fgXsu8xlVKfU+2d+dDYtRWk
+re0Eamc1BcvLcebmpwQe3Xb1KoSxsF86LljFnyTNSA+5ewyToLNL3Tz9QYT9c9+
gPIj8PPICZZnWRhC5Nm8YiKd2bKT7uafO0TuJ37NcRgEPNfgo08a9sYCYw/IMdU6
I4BSr3XQ3AJLjL7SwcCaQEdzYADc62NWyZtqmfkTuuVqFf2gzuj/w6mps065DUfY
ns1nt/Xj8DsYfUBIu3jIqBK5lF5DYesEKR3AYc5kFrB6Bhdn1c5QPofboYcp00qk
NpSuoKAO/ogVPkSqNWJ2fNeUKXjSBJxuEpCq8wSAy06dSMZaYVlvukfVwzIqCqG5
YKvLFprCpnw=
=zJhf
-----END PGP SIGNATURE-----

--=-QwdJuZnsK8IegMLTQghV--
