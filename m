From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 4/4] staging: r8192ee: Turn on build of the new driver
Date: Mon, 26 May 2014 19:06:00 +0100
Message-ID: <1401127560.17377.137.camel@deadeye.wl.decadent.org.uk>
References: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1400707536-3338-5-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qWvnFI927gmxg+aBgCcw"
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, zhangfp1@lenovo.com,
	troy_tan@realsil.com.cn
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54386 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbaEZSGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 14:06:22 -0400
In-Reply-To: <1400707536-3338-5-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qWvnFI927gmxg+aBgCcw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-05-21 at 16:25 -0500, Larry Finger wrote:
[...]
> --- /dev/null
> +++ b/drivers/staging/rtl8192ee/Kconfig
> @@ -0,0 +1,8 @@
> +config R8192EE
> +	tristate "Realtek RTL8192EE Wireless Network Adapter"

depends on MAC80211 && PCI
(at least)

> +	select FW_LOADER
> +	---help---
> +	This is the driver for Realtek RTL8192EE 802.11 PCIe
> +	wireless network adapters.
> +
> +	If you choose to build it as a module, it will be called r8192ee
[...]

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-qWvnFI927gmxg+aBgCcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4OCkOe/yOyVhhEJAQqWahAA0teh6SIr2GBWNU8Zu50pdHRu3dGrc2ab
c0yqH1y3tJn/6Mwtej+pUdysU0+5ZjAm/wIkwO6+eyVJjbbFyrZHUzok0i/KuIyK
+06eeaAMXV444oapz+KUAA213s/ViBzdAHf16CI5Wt4hKLQjCxeeNhVLDwoQO3/g
lM1gK77sdml8TIWN3KJa5gXfRw3r2bRibW3QvZFqqo3SlLrLdque50PeMrRRdi5Q
TmI4btQJRXmqGVcO7+PuMIXdYlDqDQxWDT3Yz965yjauvZ1LoQN2Q0zsQkqVkTiJ
UjvY9wls/s387fwOw766mRuv/E7YKbGJqQsfMAf8kRnWzUtIs6XPy7bJMrotK+8n
WzFnrYGq21yBQ5iFEeRn6MMslwsHMJguupMyxDuOR6xIdsOQimVSlYZAJDH0x7ai
xR3/5ZmkY3mUET6EHprxLzvqLVqOBV1EiJz3DYhz4AU+yRwqXbY4aSPiX5Vy7hV1
cGIxG7WH9otuLN77+Lu4BVitCQ0wIUOgDNcsLSurDw99tVwabbw9eHlyKXrUo8hA
U5UQHNu34cix4G8QHhwifbSML50BNDfa+9u1autGZUR2HURaDtQNTrMPdi3PzJUU
THz+rJja3Q8ZJaj3Zg0tqcjZkuvAhcSuV5+b1R+TjWH2zqVZ7z7U4b/0yHk3QDIj
WFVXsPBgAyE=
=GbAI
-----END PGP SIGNATURE-----

--=-qWvnFI927gmxg+aBgCcw--
