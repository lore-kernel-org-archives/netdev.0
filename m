From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 ethtool 0/2] IPv6 RXNFC
Date: Sun, 26 Jun 2016 01:18:00 +0200
Message-ID: <1466896680.2504.20.camel@decadent.org.uk>
References: <56EB00D6.3060003@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tgXgWZBPeCa8f3HHCiEe"
Cc: netdev@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51480 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231AbcFYXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 19:18:11 -0400
In-Reply-To: <56EB00D6.3060003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tgXgWZBPeCa8f3HHCiEe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-03-17 at 19:09 +0000, Edward Cree wrote:
> This series adds support for steering of IPv6 receive flows.
>=20
> Changes since v1:
> * Fixed and simplified IPv6 address and mask parsing
> * Made help text / man page more consistent
> * Dropped ethtool-copy.h patch as upstream is now newer

Applied these two, and added the patch below. =C2=A0Thanks for your
patience.

Ben.

---
Change IP parameter syntax in documentation to just 'ip-address'

Writing out the IPv4 address syntax repeatedly is not really
necessary, and extending it to cover IPv6 addresses will just make the
documentation harder to read.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 ethtool.8.in | 2 +-
 ethtool.c    | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 36da10ed6c87..9dc5e252a1dc 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -54,7 +54,7 @@
 .\"
 .\"	\(*PA - IP address
 .\"
-.ds PA \fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP
+.ds PA \fIip-address\fP
 .\"
 .\"	\(*WO - wol flags
 .\"
diff --git a/ethtool.c b/ethtool.c
index a92137f7f5b1..d04bf9fedafd 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4163,8 +4163,8 @@ static const struct option {
 	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ proto %d [m %x] ]\n"
-	  "			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
-	  "			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+	  "			[ src-ip IP-ADDRESS [m IP-ADDRESS] ]\n"
+	  "			[ dst-ip IP-ADDRESS [m IP-ADDRESS] ]\n"
 	  "			[ tos %d [m %x] ]\n"
 	  "			[ tclass %d [m %x] ]\n"
 	  "			[ l4proto %d [m %x] ]\n"

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-tgXgWZBPeCa8f3HHCiEe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXbxEoAAoJEOe/yOyVhhEJn30P/jm/8h5tLJadKAHfEC/vP2zw
cCBCu1c/OFsWFNQAZ4CTyvYeEo4VozFMOUk17HLtc2DvxOa7IanPLlEiNmz+mOXE
ACYcX7V/SKdiVBsMa65qXIpey02jON0TplHzkr8fQgPJoyW1cjuHUFZ8Z54bEkcV
RYm8XinMfzs24DmGKYHiGw/pphD9hRalTOWstcFsAuWpWvk4UEuChmh4UN87zmSH
cW+Vb90iH2XRtJDSq3FBsyD3YP4k+Y1jK3hPe/2nii75htHIaYN8V1EsrxJ8vO83
tqF5Ld0mnBj+mCubCdfQ98Tvjha9dB5GIRn1sZeEn8+czqVdIeWqfTOl3onaydVe
96JtKaHoEHQRzXrQIrXsmy2W7QIcFPN0AJXVzYWJxWboyf46s9QDhDqZ9v/RmRcI
ka5HfbSnF7faqcGtGbYHu+nGDnHx2FD7MkM7uS/U7BBHNZHHE0HvYQ4oW+dJO2Q4
FxLYYb22+kWKmZ09vD8rYu8ZrF/IIgdKlo6KRCekbgFN9mAg7j3Xh0VOuBbmUZkT
Y6sz+pSQ9ROw/e6J5beJdfLSF9ooiP8h7lkFAIx6KaTZQQUR9iUc6JdYwxZtlRpG
FjqiyAtfUqHBx+42PFg9eLHDd3gIyzWg6DKzmz7TPUhtIOJupls9Gjb78PypsZS3
kl3MEcZmVvF/MySZPCB3
=1mle
-----END PGP SIGNATURE-----

--=-tgXgWZBPeCa8f3HHCiEe--
