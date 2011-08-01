From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
Date: Sun, 31 Jul 2011 23:16:47 -0700
Message-ID: <1312179408.20837.142.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80FE464E9E5@MNEXMB2.qlogic.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-eeGU2xSiDcSo65xjIfUL"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>,
	Dustin McIntire <dustin@sensoria.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Hinds <dahinds@users.sourceforge.net>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35221 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602Ab1HAGQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 02:16:49 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FE464E9E5@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eeGU2xSiDcSo65xjIfUL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-31 at 23:09 -0700, Amit Salecha wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Jeff Kirsher
> > Sent: Sunday, July 31, 2011 8:56 AM
> > Subject: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
> >=20
> > Moves the SMC (SMSC) drivers into drivers/net/ethernet/smsc/ and the
> > necessary Kconfig and Makefile changes.  Also did some cleanup
> > of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
> >=20
> > CC: Nicolas Pitre <nico@fluxnic.net>
> > CC: Donald Becker <becker@scyld.com>
> > CC: Erik Stahlman <erik@vt.edu>
> > CC: Dustin McIntire <dustin@sensoria.com>
> > CC: Steve Glendinning <steve.glendinning@smsc.com>
> > CC: David Hinds <dahinds@users.sourceforge.net>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> > -config NETXEN_NIC
> > -	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
> > -	depends on PCI
> > -	select FW_LOADER
> > -	help
> > -	  This enables the support for NetXen's Gigabit Ethernet card.
> > -
> >=20
> > -obj-$(CONFIG_NETXEN_NIC) +=3D netxen/
> >  obj-$(CONFIG_NIU) +=3D niu.o
> >  obj-$(CONFIG_VIRTIO_NET) +=3D virtio_net.o
> >  obj-$(CONFIG_SFC) +=3D sfc/
>=20
> I didn't get reason for above netxen_nic changes.
>=20
> -Amit
>=20

Hmm, it looks like changes destined for the previous patch (the QLogic
patch) got applied to this patch.  I will clean this up.

--=-eeGU2xSiDcSo65xjIfUL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONkTPAAoJECTsCADr/EWUUDoH/jZcilqP+iGTAnrm3QxHkHaz
JfWqRuwAmCFru2LrMKNzfEmLV2fsuXssXL4EKl7fZ8Vsh3F00o/Mp1dFp0VPhS3i
5ert0BAjMrFtH67hDXSimUziZXxJqJkSaZN3K69pGRD17T0TALDDMhQzAVI98ew0
7OejYpFXCfu6jDTMYnshd9dsaqELPTRPb70eRRQEuE+NM6a9P+38P9Bc4mJJLd57
iPCdrzb0TcpXjZj6Tekh/Wcn8G9ICcRqLraxsi9OaYVyVJGQffu5UZAVnTeqFb0b
wCcExMcDDKSSi5LO4NjeW5IWii8B4oe8txI/LZTVpzSqL0486W5X51Dtrz2FCDY=
=UaFr
-----END PGP SIGNATURE-----

--=-eeGU2xSiDcSo65xjIfUL--

