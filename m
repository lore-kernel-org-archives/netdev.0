From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v2 00/29] Add support for the Intel FM10000
 Ethernet Switch Host Interface
Date: Mon, 22 Sep 2014 12:46:45 -0700
Message-ID: <1411415205.2513.9.camel@jtkirshe-mobl.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
	 <1411410964.2513.1.camel@jtkirshe-mobl.jf.intel.com>
	 <20140922.151750.1374374207690364454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0ej7DdQIp6DYaUBR05UD"
Cc: alexander.h.duyck@intel.com, nhorman@redhat.com,
	netdev@vger.kernel.org, john.fastabend@gmail.com,
	matthew.vick@intel.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45534 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754056AbaIVTuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 15:50:07 -0400
In-Reply-To: <20140922.151750.1374374207690364454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0ej7DdQIp6DYaUBR05UD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-09-22 at 15:17 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 22 Sep 2014 11:36:04 -0700
>=20
> > On Sat, 2014-09-20 at 19:45 -0400, Alexander Duyck wrote:
> >> This patch series adds support for the FM10000 Ethernet switch host
> >> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet sw=
itch
> >> supporting both Ethernet ports and PCI Express host interfaces.  The f=
m10k
> >> driver provides support for the host interface portion of the switch, =
both
> >> PF and VF.
> >>=20
> >> As the host interfaces are directly connected to the switch this resul=
ts in
> >> some significant differences versus a standard network driver.  For ex=
ample
> >> there is no PHY or MII on the device.  Since packets are delivered dir=
ectly
> >> from the switch to the host interface these are unnecessary.  Otherwis=
e most
> >> of the functionality is very similar to our other network drivers such=
 as
> >> ixgbe or igb.  For example we support all the standard network offload=
s,
> >> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
> >>=20
> >> ---
> >=20
> > Dave, if it makes it easier on you, I can add Alex's series of patches
> > to my net-next tree for you to pull.  Just give me an hour or so so tha=
t
> > I can update my net-next and push his patches up to my tree.
>=20
> Yeah, could you please do that?
>=20
> Thanks.

Working on it now, I will let you know when I have it pushed up to my
tree.

--=-0ej7DdQIp6DYaUBR05UD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUIHylAAoJEOVv75VaS+3O2i0QAKYmtwj9Hy9enFuvw9vQAqcW
7Y6Y94mA07gMF801bF2kPCaNq/oTnlYNNXIE2of0HhwA8Q4H8i/YxdPj/v8c0wgO
kkHvSCGT7AiJSSsynRWm8ltTGA4dAh5E+kWfeDDo74w1xCrCsgDUmlwvbTjrDjro
2wqB2Z4XFBzVL5vLKZA4vRUh2XyYvdtUkibEr67SUcGkz0X5uj0tSQIOjyxF+C0K
PiiXWbXcRiPw8CBgpMWFWxSY9tyiCI9MIA9qoj7tTQZXNKY64QyXTn300/4k2oNW
slsCpmcpjZX3dMzORwbX8rQn6VVERRnb9ZEDNfZ2Pn9xe5/uAE1onY5QheSMW5iw
FeOYQR+3CJa6NArcTCLFV5f2nmXyWM6ZYnMeoFfriQ5tGF7sPDWlmF2KJ6hnH1mf
dOlxOCGMRj95Ht00AFUvvhb6GelhC6QJ1NMDwEjNNhRZKk4XYpm5o5ck3NhvUMzb
tY23enTlU5DINLUDAbcczdIDUz+4H5LRUQEPBJ9OIEwkaD6tE+eBdrTRL53c59y0
xzV1HVYPvsBNq72LOxXU43oggNIXhU1AFzgQia/kL4dbruR/JL/+RtdpQYVrxbSq
5wrhrkJQN4fZQByoCuygk+2L/LikVOxxlBYir/RZc+TvvQ0A9Yweki4OyPIx8ey3
i5S9WJHHNZVcU5xAaDu6
=1GIH
-----END PGP SIGNATURE-----

--=-0ej7DdQIp6DYaUBR05UD--
