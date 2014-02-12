From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 06/14] ethtool: Expand documentation of struct
 ethtool_ringparam
Date: Wed, 12 Feb 2014 22:14:23 +0000
Message-ID: <1392243263.15615.10.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QR2CrnNZ89FzdqvGVSTB"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52788 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475AbaBLWOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:30 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QR2CrnNZ89FzdqvGVSTB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index d5a0d20..e602cd0 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -401,22 +401,37 @@ struct ethtool_coalesce {
 	__u32	rate_sample_interval;
 };
=20
-/* for configuring RX/TX ring parameters */
+/**
+ * struct ethtool_ringparam - RX/TX ring parameters
+ * @cmd: Command number =3D %ETHTOOL_GRINGPARAM or %ETHTOOL_SRINGPARAM
+ * @rx_max_pending: Maximum supported number of pending entries per
+ *	RX ring.  Read-only.
+ * @rx_mini_max_pending: Maximum supported number of pending entries
+ *	per RX mini ring.  Read-only.
+ * @rx_jumbo_max_pending: Maximum supported number of pending entries
+ *	per RX jumbo ring.  Read-only.
+ * @tx_max_pending: Maximum supported number of pending entries per
+ *	TX ring.  Read-only.
+ * @rx_pending: Current maximum number of pending entries per RX ring
+ * @rx_mini_pending: Current maximum number of pending entries per RX
+ *	mini ring
+ * @rx_jumbo_pending: Current maximum number of pending entries per RX
+ *	jumbo ring
+ * @tx_pending: Current maximum supported number of pending entries
+ *	per TX ring
+ *
+ * If the interface does not have separate RX mini and/or jumbo rings,
+ * @rx_mini_max_pending and/or @rx_jumbo_max_pending will be 0.
+ *
+ * There may also be driver-dependent minimum values for the number
+ * of entries per ring.
+ */
 struct ethtool_ringparam {
-	__u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
-
-	/* Read only attributes.  These indicate the maximum number
-	 * of pending RX/TX ring entries the driver will allow the
-	 * user to set.
-	 */
+	__u32	cmd;
 	__u32	rx_max_pending;
 	__u32	rx_mini_max_pending;
 	__u32	rx_jumbo_max_pending;
 	__u32	tx_max_pending;
-
-	/* Values changeable by the user.  The valid values are
-	 * in the range 1 to the "*_max_pending" counterpart above.
-	 */
 	__u32	rx_pending;
 	__u32	rx_mini_pending;
 	__u32	rx_jumbo_pending;


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-QR2CrnNZ89FzdqvGVSTB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyP+e/yOyVhhEJAQoXVBAAoComrstPrZjzci10qBY9WRNRnTHw9F2m
W3x6eSZ1lV7Zfh1PjDU8aWi+6DWfP+eaIDCbyNbp/JuxJRAwWvA3ukTFwJ7Zky87
xa7StSsryYNRsPxM4qKSAWDx+zv4CHDm3fzGUlFfAb/kPiMspbNiwMMeenaDus3A
Ch3LDaoVO7sfN3uG9eN7sW2vCWJBll3UM02Clk7xzmUlGcdo1mLGY4HutgVlrAPG
jIDyBenT7KzoSY13ZQrFVoQ5aXQGm+SQBwdZPTbOAPVbldo7NE7pGLASMnUEChPa
3vn3Z+PI73jD7fDGG+mhNTR4k7D2E9CdSc3ic8cquNHoa2CfOB4J906HzKpoz+EI
JB9NeKpIZrvOVPwW52w2NrFh3g4omuaIZUXsF9LcpdSxLxE4JuvYk8WxkSMfPphW
pYdaZ/mHG/zDuZxHfcoupfqbfqZmqxoFpTjmRiOLWKD89p4BXxWblymPCXu5CD8h
45xEAAHPBb8eV02rWavueVSdYccvXTS03JdSl36kFIgeBkjDcx3CPFhljUiAM5iC
usuxDUn+bUNLVnDo8rgzSKbVOJn44U8F7HhQ8ER6UnvbazAlsL5Z8HcTgC9DU9AF
0qHIyXk9qQeEoMFl5cqmcAWycb3MoGpR3FrRtktjixObGNDzMRNG6ATg5PSEVVpY
U3DyT+gfnDU=
=CSho
-----END PGP SIGNATURE-----

--=-QR2CrnNZ89FzdqvGVSTB--
