From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Thu, 16 Nov 2006 18:49:42 +0100
Message-ID: <1163699382.3392.9.camel@johannes.berg>
References: <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong> <1161681021.2840.23.camel@ux156>
	 <1161764889.8668.13.camel@devlinux-hong> <1161766245.2767.17.camel@ux156>
	 <1163470978.7789.31.camel@devlinux-hong> <1163607901.2705.53.camel@ux156>
	 <1163670762.2763.19.camel@ux156> <20061116172131.GA7404@instant802.com>
	 <1163698700.3392.7.camel@johannes.berg>
	 <20061116174053.GA7531@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jlrM0Dyxx7xqIfCZ5Kq/"
Cc: Hong Liu <hong.liu@intel.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35037 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1031147AbWKPRvT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 12:51:19 -0500
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061116174053.GA7531@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jlrM0Dyxx7xqIfCZ5Kq/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-16 at 09:40 -0800, Jouni Malinen wrote:

> It's been awhile since I working on this part, but if I remember
> correctly, this can be done easily by the driver behaving different
> based on the frame being fragmented or not (it is fragmented if MoreFrag
> flag is set or seq# !=3D 0). That's the way it was done with hardware
> designs that allow full TKIP hwaccel for MSDUs that are not fragmented,
> but require software implementation of Michael MIC if MSDU is
> fragmented.

Oh right, I forgot that the driver can just look into the 802.11 header,
was checking tx_control only :)

johannes

--=-jlrM0Dyxx7xqIfCZ5Kq/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVyktaVg1VMiehFYAQJ0Jg/+J+8KKWJVTZOp1oRJx5ctw+ncAjCDyfyR
CC3v4WrtdsLV+UBlYFINdt4bwdYtmcXtu1RC0QzQKl39PUGPDJqROAyAKzRiKmzb
/h5A70Ug45Krn5BnTxWl4A0CKhf4vOcTkezpJKVaUAEo26/K9AOnWc1w5EaQmg8j
ofF9i1zqd12dnB8ka7BivzCK5n5EXgU7wTmkqFZ8FL7YRW+G6VJ/AQ79UGXwORHa
hz11GVsFgyJ970qKUEycxo3g5n/eA1XA7t00Yz23d29m5cmRFn71nEPGswyCMOMg
cD0ZcV8qF10X7wyiOh8zS4UsrToj1haHvtDCH7kn67NuWjyF+68PBY1RXseIqlUX
VBDMexZ8EoCbm/nlMn+zBGbjxX64t3mmJq/5Dc6q0t5xGQrDYKcOBxF0vdRZPAlL
KV/525n/iYlCT+cLkHcH5aG4a9xamTjwPA9eaD1y/XfgO9DmSrT/e+2m4NSHA3+e
LE68IiIFLbFqvu95grfH56kFydg9r9O65fyVe3oTJ9lLC5GtpDSXdqgfk+4hsFVl
yU0DQ1YOFoFqB+85slv3p7Q39eyfxfmbWlWbRAk+JR1KWzKzdFzeOabeGXAEsZv+
AyLV+QLEsRutXusUpR67Bw6s/+DNfKSo56DaAtcVhuG9GCTwZy9ttaNFkTwWh1Qs
RothKCiExCk=
=DZUL
-----END PGP SIGNATURE-----

--=-jlrM0Dyxx7xqIfCZ5Kq/--

