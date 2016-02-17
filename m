From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V3
Date: Wed, 17 Feb 2016 13:24:01 -0800
Message-ID: <1455744241.2958.14.camel@intel.com>
References: <56C4167B.7080705@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Z7SSC/BhEsr9vKxm3RC8"
To: John Holland <jotihojr@gmail.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34648 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423553AbcBQVYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 16:24:03 -0500
In-Reply-To: <56C4167B.7080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Z7SSC/BhEsr9vKxm3RC8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-17 at 07:43 +0100, John Holland wrote:
> Hello,
>=20
> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP
> and has no externel EEPROM interface [1]. The following allows the
> driver to pickup the MAC address from a device tree blob when
> CONFIG_OF
> has been enabled.
>=20
> [1]http://www.intel.com/content/www/us/en/embedded/products/networkin
> g/i211-ethernet-controller-datasheet.html
>=20
> Changes V2
> - Restrict searching for compatible devices to current pci device.
>=20
> Changes V3
> - Add device tree binding documentation.
>=20
> Signed-off-by: John Holland<jotihojr@gmail.com>
> ---
>=20
> =C2=A0 Documentation/devicetree/bindings/net/intel,i210.txt | 36
> ++++++++++++++++++++++++++++++++++++
> =C2=A0 drivers/net/ethernet/intel/igb/igb_main.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 30
> ++++++++++++++++++++++++++++++
> =C2=A0 2 files changed, 66 insertions(+)

Does not apply cleanly to my tree, please make sure you rebase your
patches based off my dev-queue branch on my next-queue tree.
--=-Z7SSC/BhEsr9vKxm3RC8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWxOTxAAoJEOVv75VaS+3O6gEQAIo8+8qwrnuwWFinfu+iSpqe
DgGTVUYW3sE5Zq2DV6yJDX1WjfbmWsWnPzM1mpRaRrnJF8EcA+zECoUQQpjt1RPP
xOE3GqCoUnoxdF0ffcwQiNCGwSmiCXJdbiqr3Tf8bzAVwZZfsUzB1WmuCkD2Yhow
DGHk5XM7Jc4Nk2+xzOx/1dxZKqlR/TV/dM8yCcGLZHGH2hUyA7+WVWFHVlZLPcCB
dDjkWd4L8Pu7VUQCqtJxki/RHFLM6c48lNVUVHXqjm5uwVibp7fv+X3XzigWSBkO
YvK99GTrqUOjXeCDCTJEpVZ1rcd+4gG/dRmcT6z1uzte84PL40VPKcM7Aq0l5P3H
pwHA6wSs2wZXkZOOpxi4vCIBDEgBF2xLiaweTPJ3Ba0BWu7W9/SVxEq73MnrDPKt
0BZig4IRO83MWBBXZyzfolIXyqy+f2urQD9RCRhYRZUxn3buLETVtcJV7F11b2Uy
wBwztM70bM4sMR7K0v46zDkSfCGa2mr9y/TeeSW+V564jGm0RMNhAq7wyfGUE5k5
1AzlLpaxNbRztcBcSadk1k6u84JxscxH2JUY70j+/6e6YRpgJ6aC1MmpEiJRnRIl
nJSxR+fn4xlVS7gK7+BvTzdwtnisFFOiRsnP8cHW07khm+JUifVf24apmsdG7db9
pGcUbyc9Th9u/4P9QcUf
=QIx8
-----END PGP SIGNATURE-----

--=-Z7SSC/BhEsr9vKxm3RC8--
