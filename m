From: Harald Welte <laforge@netfilter.org>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 16:09:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916140918.GF810@obroa-skai.de.gnumonks.org>
References: <200309022116.41697.bdschuym@pandora.be> <200309132159.37834.bdschuym@pandora.be> <20030915155903.12a3f95d.davem@redhat.com> <200309160805.08171.bdschuym@pandora.be> <20030915230259.79f5a545.davem@redhat.com> <1063703910.5948.85.camel@henrik.marasystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UBnjLfzoMQYIXCvq"
Cc: "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <1063703910.5948.85.camel@henrik.marasystems.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UBnjLfzoMQYIXCvq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 16, 2003 at 11:18:34AM +0200, Henrik Nordstrom wrote:
> tis 2003-09-16 klockan 08.02 skrev David S. Miller:
>=20
> > Also, another solution could be to store the object inside the kernel
> > using a different structure, one where you can guarentee the alignment
> > of these things properly.
>=20
> unfortunately iptables does not allow such differences between userspace
> and kernel representation..

yes. yes. yes.  The whole 'kernel internal data structure exported to
userspace' is a fundamental design flaw of iptables.  There's nothing we
can do about it, we'll have to live with it :(

That's why the yet-to-be-completed pkttables will use what I call vTLV's
(versioned TLV's) for all [netlink based] kernel-userspace
communication.

> Henrik Nordstrom <hno@marasystems.com>
> MARA Systems AB

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--UBnjLfzoMQYIXCvq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/ZxmNXaXGVTD0i/8RAhomAJ90D0355YCD4jhTTPCOuvrndQ5YDACfcwaW
UKucSJjwFt8GlCxUCXPT2CY=
=AwWI
-----END PGP SIGNATURE-----

--UBnjLfzoMQYIXCvq--
