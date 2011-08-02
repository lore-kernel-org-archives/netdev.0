From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 28/71] 8139*/atp/r8169/sc92031: Move the Realtek
 drivers
Date: Mon, 01 Aug 2011 20:41:07 -0700
Message-ID: <1312256485.2294.3.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312244694.2591.42.camel@deadeye> <4E376D30.6050406@pobox.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Wg2w7WqyYeu5u/iND8Zk"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Donald Becker <becker@scyld.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12875 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027Ab1HBDl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 23:41:26 -0400
In-Reply-To: <4E376D30.6050406@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Wg2w7WqyYeu5u/iND8Zk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 20:21 -0700, Jeff Garzik wrote:
> On 08/01/2011 08:24 PM, Ben Hutchings wrote:
> > On Sat, 2011-07-30 at 20:26 -0700, Jeff Kirsher wrote:
> >> Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
> >> the necessary Kconfig and Makefile changes.
> > [...]
> >
> > Does it really make sense to move the pci-skeleton driver?  Although it
> > includes hardware access specific to RTL8139 chips, that's not really
> > the point of it.
>=20
> Indeed.  pci-skeleton was simply intended to illustrate a clean driver=
=20
> for a simple DMA-driven NIC.
>=20
> Honestly, it's so outdated now that deletion would be a better course.

If it would be useful, should we take the time to update pci-skeleton
driver?  Or will this be a maintenance issue going forward and deletion
is the best answer?

--=-Wg2w7WqyYeu5u/iND8Zk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJON3HTAAoJECTsCADr/EWU4zcIAIS5Vhql5udCGSSihSZGS6EU
963R1PVGzHCfkDlfE0IsOep2dQ7H0WlZf38ZSHI/JO+AzsnVKZ0xc9zMtx1dv4Bb
yp3btZKvZJeZT6GKqkDPZsMD6eUS8Jlp9Ha9PihXFnVi4uJCH5JNXPdPN6JyDscA
sDeq8Zrdeea5Juw+PbW7Otzrn7sjnFAAbTKIXSnoMjsKtdEbHLvPwcBS4DdhzP8U
OIote3szbMtC9KabaG1jbjHewlGBckbSfVAMoGj4PEJ/ZYzd4ysmevFKEzFC4ELm
KZhwVwk2FhmWW9D21/F5VX69COI4goO0Eytze6W3N6Xe4IdnhO3F5c1nUnpuqAI=
=WyKU
-----END PGP SIGNATURE-----

--=-Wg2w7WqyYeu5u/iND8Zk--

