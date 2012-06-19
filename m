From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: simplify padding and length checks (v2)
Date: Tue, 19 Jun 2012 16:30:51 -0700
Message-ID: <1340148651.1988.33.camel@jtkirshe-mobl>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
	 <4FDF9B37.3030804@intel.com>
	 <20120618163111.4e46493b@nehalam.linuxnetplumber.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WzU6gup42Vk98BTHR9za"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6521 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844Ab2FSXbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 19:31:47 -0400
In-Reply-To: <20120618163111.4e46493b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WzU6gup42Vk98BTHR9za
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-06-18 at 16:31 -0700, Stephen Hemminger wrote:
> The check for length <=3D 0 is bogus because length is unsigned, and
> network
> stack never sends zero length packets (unless it is totally broken).
>=20
> The check for really small packets can be optimized (using unlikely)
> and calling skb_pad directly.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>=20

I just realized I had not responded to this updated patch.

Thanks Stephen, I have dropped your previous 2 patch series and added
this patch to my queue.

--=-WzU6gup42Vk98BTHR9za
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP4QurAAoJEOVv75VaS+3OF9gQAJ/HlIGQWhX5is8dQnMizQzt
SioL2GhIrVo8M8MIpDu8Wu9O5xlW9ZycJxNKT+LUVVMdmLziBcCMBLfMusmxhGrk
GlggAOGCZYCC5TwyNzsnrxPkvjBruzxSOou8WFEycZoHdnjpMKZoUdMqujiH6AZ2
mjx0aejtRTXtZdlZ2WbUXmtfyy7u0Tmhd2agp3g6NClLq1ZQafgyCd4JOm9m9TD/
7BY8FCz2TMxDKaJtrEefk6Vu/KBeB+uaEhxpR1T+EYS4v/45h1IsrNjgxRGhZrsd
ViTnCydu+mTEPyL93JzxD7eofPJhx2viyOHbuaD8riAubrHZ0pzOMTzRI8WmF07L
JLiZ/jqp0OQzCJd1GxRmCT8+L/WQCvdpPTRIc9vtHlmnCQ62zGN7/XRawb95J0aX
ot0SiYd97GrHbZeTjQ5leYbVs1OmlqvDNc4yky5aCbLi6m+s7zrVcyKDwxgVflHJ
7m4r2wbjfz6/4+ecFRhfMV8vJ5kmDo3UrvIwmeiM9jTtYDe1gF7aj0zmJbQ2BSLI
PZtiexuPKrSvhfFDO8hqWqBFoRd87lxCy4+0ltOvdM5jjjWwfXBMQveclnbNePa8
RNv4FFgBUcubQVeXwYs8BP612F8j6ItkhTP3GcfWd9nR4WZOUniGkkNghLlZJs9l
8FXvEKcmerySM8B70gNA
=VGZ5
-----END PGP SIGNATURE-----

--=-WzU6gup42Vk98BTHR9za--
