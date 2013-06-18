From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/3] at91_ether: Do not select NET_CORE
Date: Tue, 18 Jun 2013 03:27:29 +0100
Message-ID: <1371522449.3495.65.camel@deadeye.wl.decadent.org.uk>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cT47Sg/64oi/pgi3uqJj"
Cc: netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Joachim Eastwood <manabian@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51474 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753920Ab3FRC1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 22:27:36 -0400
In-Reply-To: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cT47Sg/64oi/pgi3uqJj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This has no dependency on any of the drivers under NET_CORE.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/cadence/Kconfig |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/ca=
dence/Kconfig
index 768285e..8030cc0 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -23,7 +23,6 @@ if NET_CADENCE
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
 	depends on GENERIC_HARDIRQS && HAS_DMA
-	select NET_CORE
 	select MACB
 	---help---
 	  If you wish to compile a kernel for the AT91RM9200 and enable



--=-cT47Sg/64oi/pgi3uqJj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb/Fkee/yOyVhhEJAQoaWA//QQ8sT10ipXDYwL2l0m5o1vPXBa8rmTqQ
VgeMzAQVxhnNvAwss+yJeGfWeREp6VKLXHFIk0db6vmuO3GAatAvX1gTvvjF3czs
MYlgh1Fddsnlq5+GXpn78h06fxV1hKlrIHdRcWr0Jpv7dBagXHwjvTHO68+VPY0w
wndJFUEL+Fy+/Dl+3ZTDIvsVtBbQ2PUCOCZgzGy/UyqrTDM26IqYc88Nfz3VQnKa
BmANceowVPTn0RZm5yNujA68gXjin/jwWYkZRGGDrYFUEWncmGjDRBXdXcCcI8Ud
ReUAGpJMe1L9e8D03gNeQancxIEywik7ynBL3vqGaBoKfP+sNYVtDEPZhxttJULH
+rtIPgQd2CEALr4UWvZCiGgGq8pWvnmirF8ucdV73kwIWsW9qcaT/o4PegoLbm4u
xBGdjw9myCPYBr/UnxKZaZJHXw2LYX7Gw33RVTvtAGNAfr5bABaOL2gDbHdlgT9T
KhqQ62DOPwiS6DTlbCYcZizYrb5KkMY2V7M35ruz47ZsLxCRxIHXyClQxmO5FeTc
XeQ9I7P++nAzpkiSQk6glLewhSvLfEI3+ubrHKCuHCMQRsj4kbFdwinCrvT7Zs33
VYEeHe/Fl3q3HtO44GwY7pKKE6e8BTEdkczw0RMtFHy29EhnD0g12HCXDo+fS4j+
0qzhE42ach8=
=NheI
-----END PGP SIGNATURE-----

--=-cT47Sg/64oi/pgi3uqJj--
