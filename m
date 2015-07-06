From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2] add stealth mode
Date: Mon, 06 Jul 2015 06:49:58 -0400
Message-ID: <21611.1436179798@turing-police.cc.vt.edu>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1436179798_2178P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 02 Jul 2015 10:56:01 +0200."
             <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1436179798_2178P
Content-Type: text/plain; charset=us-ascii

On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.

A few notes.....

1) Do you have an actual use case where an iptables '-j DROP' isn't usable?

2) You *do* realize that this isn't anywhere near sufficient in order
to actually make your machine "invisible", right?  (Hint: What *other*
packets can be sent to a machine to provoke a response?)

3) At least my copy had massive whitespace damage, where all the tab characters
appear to have evaporated....

--==_Exmh_1436179798_2178P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVZpdVgdmEQWDXROgAQIqdw/8Dk+V9uKX42XZoioysdADjuNU0cMC+OSD
qvvBtRD96Xr9/A0o9rQbM4VczTJsceWRSl41WaGcplJQL+RrWB56m+SMQ4wdRxWm
oyRqA3CqcxNk6EjINcn+x4rWYWhRs3o753GvNnJjM8oTD3BE5OnZPzJyAJAqD2k6
Wu+LK0lTOVkKpXBMRdUwM/61syLkLYoWFdq8oemDLjVcZm3st/4EJ1gH3/Kex+BT
zUSH0N7wTO+e7dBqAahxLmcgQjMYQBA8QEngzuaofr/efOXX9bIbgjUDIHu6Mwvl
XTLQFpl/vKE+1C5hcXHy9ZrWG9sw09nGC9L/eB4Eyubstuah0F+KhxLrlqVC1GdD
g3PIPYmhlf9LjmzJJ/5Jv3G62MjdEJNfH32xg27/wB3A3C3MSSYS4j77yK7reqJk
dCJtx3Dbl/iq1XM5wrIT5HgovEo3wzqezzLKwDLjNg0mBl1YyPPVzx6sxfgC6wPm
M1pAImivZAku6qkWpNmtXPn4z9OMEENec+QWfunklaOJfmhGVfUlDp1gd/1ms9I7
tv/h4X11qmPpxiJlv8U2oQ5E/stFsPFbzW4T+UEOYsMqRGqAcrYE/aj3Tb0KTUP1
/PWDsbnDgqBVyc5zTUfEK3ikpVZXQgo1cHyDUUh525yhsZ7XKOaYqyWCTBC1NM7Q
VrbvxCuhLH4=
=/NGi
-----END PGP SIGNATURE-----

--==_Exmh_1436179798_2178P--
