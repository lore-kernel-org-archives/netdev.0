From: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Subject: Re: [PATCH] prism54 tree sync update
Date: Thu, 18 Mar 2004 01:07:18 -0500
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040318060718.GE19391@ruslug.rutgers.edu>
References: <20040317063659.GC24063@ruslug.rutgers.edu> <40581F1D.5090704@pobox.com>
Reply-To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5I6of5zJg18YgZEa"
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40581F1D.5090704@pobox.com>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--5I6of5zJg18YgZEa
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Content-Disposition: inline


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 17, 2004 at 04:49:17AM -0500, Jeff Garzik wrote:
> Luis R. Rodriguez wrote:
> >Attached patch has been well tested. It updates 2.6.5-rc1 prism54
> >sources to our latest work (which had also previously been tested).
> >Some additional new kernel updates were integrated as well.
>=20
> Applied to 2.6, after splitting up into the two attached patches.
>=20
> Please double-check that no changes were missed, and send a patch=20
> incremental to the attachments if so.

Jeff,

I've checked your patch and two chunks were missing. Attached patch is a di=
ff of
2.6.5-rc1-jeff and 2.6.5-rc1-mcgrof which completes the changes.

	Luis
--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-c
Content-Transfer-Encoding: quoted-printable

diff -Naur linux-2.6.5-rc1-jeff/drivers/net/wireless/prism54/islpci_dev.c l=
inux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.5-rc1-jeff/drivers/net/wireless/prism54/islpci_dev.c	Thu Mar =
18 06:02:50 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_dev.c	Wed Ma=
r 17 01:00:42 2004
@@ -577,6 +577,7 @@
 		if (!(skb =3D dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2))) {
 			/* error allocating an sk_buff structure elements */
 			printk(KERN_ERR "Error allocating skb.\n");
+			skb =3D NULL;
 			goto out_free;
 		}
 		/* add the new allocated sk_buff to the buffer array */
@@ -711,7 +712,7 @@
 #endif
=20
 	/* allocate a private device structure to the network device  */
-	priv =3D ndev->priv;
+	priv =3D netdev_priv(ndev);
 	priv->ndev =3D ndev;
 	priv->pdev =3D pdev;
=20

--DocE+STaALJfprDB--

--5I6of5zJg18YgZEa
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAWTyWat1JN+IKUl4RAtXYAJ9QJ3iSTkkJPUaZyhyPmvAzR3MvVACdFZBf
eTMTENmfGPlKZ/BvsbpDqaI=
=SWis
-----END PGP SIGNATURE-----

--5I6of5zJg18YgZEa--
