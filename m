From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [patch 2/3]
	drivers/net/wireless/prism54/islpci_hotplug: Use the DMA_{64,
	32}BIT_MASK constants
Date: Mon, 7 Mar 2005 12:29:57 -0500
Message-ID: <20050307172957.GW3936@ruslug.rutgers.edu>
References: <20050306222355.6686C1ED3D@trashy.coderock.org>
	<20050307171418.GT3936@ruslug.rutgers.edu>
	<422C8E48.9000006@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0741743973=="
Cc: tklauser@nuerscht.ch, netdev@oss.sgi.com,
	prism54-devel@prism54.org, domen@coderock.org,
	prism54-private@prism54.org
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422C8E48.9000006@pobox.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0741743973==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="F67xnxMyVwCoXwbx"
Content-Disposition: inline


--F67xnxMyVwCoXwbx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 07, 2005 at 12:24:24PM -0500, Jeff Garzik wrote:
> Luis R. Rodriguez wrote:
> >On Sun, Mar 06, 2005 at 11:23:55PM +0100, domen@coderock.org wrote:
> >
> >>Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
> >>when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()
> >>
> >>Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
> >>Signed-off-by: Domen Puncer <domen@coderock.org>
> >>---
> >>
> >>
> >>kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
> >>1 files changed, 1 insertion(+), 1 deletion(-)
> >>
> >>diff -puN=20
> >>drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_wire=
less_prism54_islpci_hotplug drivers/net/wireless/prism54/islpci_hotplug.c
> >>---=20
> >>kj/drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_w=
ireless_prism54_islpci_hotplug	2005-03-05 16:12:02.000000000 +0100
> >>+++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05=
=20
> >>16:12:02.000000000 +0100
> >>@@ -125,7 +125,7 @@ prism54_probe(struct pci_dev *pdev, cons
> >>	}
> >>
> >>	/* enable PCI DMA */
> >>-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
> >>+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
> >
> >
> >Is this 2.4 backward compatible? If not we'll have to add to 2.4 compat
> >file on prism54.
>=20
> Not compatible, but it is preferred to patch the file and add that=20
> definition to a compat header.
>=20
> For pci_module_init(), it is preferred to keep pci_module_init() rather=
=20
> than adding compat gunk.
>=20
> 	Jeff

Alright, I'll add DMA_32BIT_MASK through compat and leave
pci_module_init as is.  That said:

Patch 1 applied
Patch 2 will be applied after compat work
Patch 3 rejected per Jeff's recomendation due to 2.4 compat

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--F67xnxMyVwCoXwbx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCLI+Vat1JN+IKUl4RAjenAJ4gOoXFlfjwa8fRMT7on6kEn9qDsQCgqAU8
umlrOS+3w7ZhM5BI0l5ilzo=
=jMD9
-----END PGP SIGNATURE-----

--F67xnxMyVwCoXwbx--

--===============0741743973==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0741743973==--
