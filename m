From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 14/14] ethtool: Fix unwanted section breaks in
 kernel-doc
Date: Wed, 12 Feb 2014 22:15:09 +0000
Message-ID: <1392243309.15615.18.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ozdQsom3H3kufro01sv3"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52822 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbaBLWPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:15:17 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ozdQsom3H3kufro01sv3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

A colon almost unavoidably starts a new section.  The script should be
changed to provide a way to avoid this, but for now reword the
comments to avoid using colons.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 24418ac..fd161e9 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -351,17 +351,18 @@ struct ethtool_modinfo {
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
  *
- * Each pair of (usecs, max_frames) fields specifies this exit
- * condition for interrupt coalescing:
+ * Each pair of (usecs, max_frames) fields specifies that interrupts
+ * should be coalesced until
  *	(usecs > 0 && time_since_first_completion >=3D usecs) ||
  *	(max_frames > 0 && completed_frames >=3D max_frames)
+ *
  * It is illegal to set both usecs and max_frames to zero as this
  * would cause interrupts to never be generated.  To disable
  * coalescing, set usecs =3D 0 and max_frames =3D 1.
  *
  * Some implementations ignore the value of max_frames and use the
- * condition:
- *	time_since_first_completion >=3D usecs
+ * condition time_since_first_completion >=3D usecs
+ *
  * This is deprecated.  Drivers for hardware that does not support
  * counting completions should validate that max_frames =3D=3D !rx_usecs.
  *
@@ -809,7 +810,7 @@ struct ethtool_rx_flow_spec {
  * %ETHTOOL_SRXCLSRLINS may add the rule at any suitable unused
  * location, and may remove a rule at a later location (lower
  * priority) that matches exactly the same set of flows.  The special
- * values are: %RX_CLS_LOC_ANY, selecting any location;
+ * values are %RX_CLS_LOC_ANY, selecting any location;
  * %RX_CLS_LOC_FIRST, selecting the first suitable location (maximum
  * priority); and %RX_CLS_LOC_LAST, selecting the last suitable
  * location (minimum priority).  Additional special values may be
@@ -949,8 +950,9 @@ struct ethtool_get_features_block {
 /**
  * struct ethtool_gfeatures - command to get state of device's features
  * @cmd: command number =3D %ETHTOOL_GFEATURES
- * @size: in: number of elements in the features[] array;
- *       out: number of elements in features[] needed to hold all features
+ * @size: On entry, the number of elements in the features[] array;
+ *	on return, the number of elements in features[] needed to hold
+ *	all features
  * @features: state of features
  */
 struct ethtool_gfeatures {

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-ozdQsom3H3kufro01sv3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvybee/yOyVhhEJAQoriA/+L8Nan+H0KVXOXjpGeKZeehNmJLdGpiON
Fw34PrVBDDwL/3MQApsQ9ZrqxDdNci5ZmZDGeZAZiK0lETf5aznzrbcQaQkOdaAX
AZAWz+PaKeZcPn9ADfkswgQYwtAe1pi2p12mjKK7Dun9eG9fXczWlz4aDkeQzGGs
vwAr8uYmuiVu1YQm0c1KKXBh4Kol7VZthwCof4W45s9cZdUDpBzRzVoMd5SjFu+S
ZCDGhiiP15I/V7xJEsP0CenF98BVsVtt9Ip/H2hRRqm6EVwjwFyfxZ2UcGJ6Aoul
XibU9/Xv0flf8dZGHdpuf7J2+86vsRkoLTkp/OFvJbtHHOIIhEe+pFT4oF4wkpRE
AoyY7W/SOGSquWwBbWko9Je9inWd6emOyi9DVmL+Mjdsw9KLOSoWNuuaWoZBEEO4
2FNlgjN25/F/c7N2DBqknyl7x55UjUuga9j6PGOD2F9WXsWu1KhUTzdh3SLUuKU2
f/eSurMcEIaZ+zX2uUZd/+k+EZSiK95ANEu+n8BKvT6YwoPhp9fiWu2MzRAXuHWP
2wr7hAU3jcSG+2DrH9Lu7LqkJ64ahVSpJHB7xURseYvjvBR1cpQXNjtGSAOP6XUf
KPDfgz/xL7cJVEnexH234YZWiXfjbWFg1lky6l1RrVMSeX7YK+wA9eCCI1trBGrO
zcLAdgr4S6Q=
=5ouo
-----END PGP SIGNATURE-----

--=-ozdQsom3H3kufro01sv3--
