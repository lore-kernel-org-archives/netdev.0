From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [Prism54-devel] Re: [PATCH 5/14 linux-2.6.7-rc1] prism54: new prism54 kernel compatibility
Date: Fri, 28 May 2004 18:15:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528221520.GF3330@ruslug.rutgers.edu>
References: <20040524083220.GF3330@ruslug.rutgers.edu> <1085388830.2780.9.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p5RmKVcV08d4tiXP"
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Arjan van de Ven <arjanv@redhat.com>
Content-Disposition: inline
In-Reply-To: <1085388830.2780.9.camel@laptop.fenrus.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--p5RmKVcV08d4tiXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 24, 2004 at 10:53:50AM +0200, Arjan van de Ven wrote:
> On Mon, 2004-05-24 at 10:32, Luis R. Rodriguez wrote:
> > 2004-03-20      Margit Schubert-While <margitsw@t-online.de>
> >=20
> > * isl_38xx.[ch], isl_ioctl.c, islpci_dev.[ch], islpci_eth.c
> >   islpci_hotplug.c, islpci_mgt.[ch], oid_mgt.c: Adopt new
> >   prism54 kernel compatibility.
> >=20
> > * prismcompat.h, prismcompat24.h: New compatibility work
>=20
>=20
> ewwww this makes the driver quite a bit less readable!
>=20
> for example
>=20
> -#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,0)
> -       /* This is 2.6 specific, nicer, shorter, but not in 2.4 yet */
> -       DEFINE_WAIT(wait);
> -       prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
> -#else
> -       DECLARE_WAITQUEUE(wait, current);
> -       set_current_state(TASK_UNINTERRUPTIBLE);
> -       add_wait_queue(&priv->reset_done, &wait);
> -#endif
> +       PRISM_DEFWAITQ(priv->reset_done, wait)
>=20
> why not just make a DEFINE_WAIT() and prepare_to_wait() macro for 2.4
> instead ?? so that you can just have the 2.6 version in the code and do
> 2.4 compat in a clean header, as opposed to fouling up the entire driver
> with it.

Thanks for the comment Arjan. This will be fixed.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--p5RmKVcV08d4tiXP
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAt7n4at1JN+IKUl4RAoGcAJ47A9DbjPkHr6HR5mMMdWQSc/c5rACfecmL
s3R3MYt2YjatTpMO0ohz6qE=
=vb5B
-----END PGP SIGNATURE-----

--p5RmKVcV08d4tiXP--
