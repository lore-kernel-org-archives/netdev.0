From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [patch 2/3] drivers/net/wireless/prism54/islpci_hotplug: Use the DMA_{64, 32}BIT_MASK constants
Date: Mon, 7 Mar 2005 12:14:18 -0500
Message-ID: <20050307171418.GT3936@ruslug.rutgers.edu>
References: <20050306222355.6686C1ED3D@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1G7eoSzW1hxPALpv"
Cc: prism54-private@prism54.org, netdev@oss.sgi.com, tklauser@nuerscht.ch
To: domen@coderock.org
Content-Disposition: inline
In-Reply-To: <20050306222355.6686C1ED3D@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--1G7eoSzW1hxPALpv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 06, 2005 at 11:23:55PM +0100, domen@coderock.org wrote:
>=20
> Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
> when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()
>=20
> Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
>=20
>=20
>  kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>=20
> diff -puN drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_=
net_wireless_prism54_islpci_hotplug drivers/net/wireless/prism54/islpci_hot=
plug.c
> --- kj/drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net=
_wireless_prism54_islpci_hotplug	2005-03-05 16:12:02.000000000 +0100
> +++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05 16:=
12:02.000000000 +0100
> @@ -125,7 +125,7 @@ prism54_probe(struct pci_dev *pdev, cons
>  	}
> =20
>  	/* enable PCI DMA */
> -	if (pci_set_dma_mask(pdev, 0xffffffff)) {
> +	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {

Is this 2.4 backward compatible? If not we'll have to add to 2.4 compat
file on prism54.
=09
	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--1G7eoSzW1hxPALpv
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCLIvqat1JN+IKUl4RAqB5AKCwsKQDC/pvMc0GQQPzeTP3hBeE1gCcCupp
yRL9OwKd83/W2RHdLaSW+jQ=
=Qg/A
-----END PGP SIGNATURE-----

--1G7eoSzW1hxPALpv--
