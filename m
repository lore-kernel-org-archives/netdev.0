From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 28/71] 8139*/atp/r8169/sc92031: Move the Realtek
 drivers
Date: Mon, 01 Aug 2011 20:58:40 -0700
Message-ID: <1312257521.2294.13.camel@jtkirshe-mobl>
References: <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312244694.2591.42.camel@deadeye>	<4E376D30.6050406@pobox.com>
	 <20110801.204840.1467588276691539635.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-shGH2FjN2ZuDz3BLwolp"
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"becker@scyld.com" <becker@scyld.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32462 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521Ab1HBD6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 23:58:42 -0400
In-Reply-To: <20110801.204840.1467588276691539635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-shGH2FjN2ZuDz3BLwolp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 20:48 -0700, David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Mon, 01 Aug 2011 23:21:20 -0400
>=20
> > On 08/01/2011 08:24 PM, Ben Hutchings wrote:
> >> On Sat, 2011-07-30 at 20:26 -0700, Jeff Kirsher wrote:
> >>> Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
> >>> the necessary Kconfig and Makefile changes.
> >> [...]
> >>
> >> Does it really make sense to move the pci-skeleton driver?  Although
> >> it
> >> includes hardware access specific to RTL8139 chips, that's not really
> >> the point of it.
> >=20
> > Indeed.  pci-skeleton was simply intended to illustrate a clean driver
> > for a simple DMA-driven NIC.
> >=20
> > Honestly, it's so outdated now that deletion would be a better course.
>=20
> Yeah, this is probably true.

Ok, I will remove it.

I will put together a v3 of the series.

--=-shGH2FjN2ZuDz3BLwolp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJON3XwAAoJECTsCADr/EWUCcsH/1HGMeqZHU6Ok/RAnJlZ7vsH
kd4+OCfticlX22uXZJtXy3tlQPQjNKEPmzjJ8sNgovHVYqz0TZ7/7h+OkalHVY26
Q0Cq2rFZj8ByNzZcn6ULuLf8+P7eliGK965l5evLqF2nX+H91DAahl659KQKOPpC
dbX2jLHtjV6Hlx8Pcfyxp5vJLxPrQC9PlohdYfbxg8mMoi9ChkUocduTqGr4dqEZ
Blgs0ISnFEzTphDH9YpVAJfE7Ui27IcoaOkQjJwOF0d3xV+yH9BR1XuVWfqYceOT
nraIs9sF7RAlCGNkEQPySGwsYeEttoZwAJobnW4h97qjjT0xQRFusmakor4maPk=
=KgoE
-----END PGP SIGNATURE-----

--=-shGH2FjN2ZuDz3BLwolp--

