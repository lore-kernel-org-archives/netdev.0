From: Harald Welte <laforge@netfilter.org>
Subject: Re: Big set of networking updates
Date: Thu, 19 Aug 2004 14:15:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819121542.GU3921@sunbeam.de.gnumonks.org>
References: <20040818173736.7ad8e58a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RvF2KG9p4DaV8yF8"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040818173736.7ad8e58a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RvF2KG9p4DaV8yF8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 18, 2004 at 05:37:36PM -0700, David S. Miller wrote:
=20
> A lot of things are accumulating for 2.6.9-preX while Linus
> is away.  So I figured best to post what I have in my tree
> so we can begin to weed the problems out.

I'll start running and testing those patches.

> Detailed changelong is attached, and the changes are available
> in two forms:
>=20
> BK:	bk://kernel.bkbits.net/davem/net-2.6
> PATCH:	ftp://ftp.kernel.org/pub/linux/kernel/people/davem/net-2.6.9.diff.=
gz
>=20
> Harald, all of your netfilter updates are in here.  I had to fixup
> a bunch of things to get the build and module symbol exports clean.
> In particular have a look at changesets:
>=20
> 1.1862: [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct().=
=20
> 1.1863: [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalon=
e.
> 1.1864: [NETFILTER]: Need to export ip_ct_log_invalid to modules.

I trust your decisions ;)

Forgive my ignorance, but how can I access those changesets without
having to run proprietary bk software (couldn't find it on http://www.bkbit=
s.net/ web frontend)?

> Enjoy.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--RvF2KG9p4DaV8yF8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBJJnuXaXGVTD0i/8RAhArAJoDDlxL2kf/QJnUiY9qmtj44l0V7wCgsU3M
+45z9M9UJGlKr71qMk4jpTg=
=gUtL
-----END PGP SIGNATURE-----

--RvF2KG9p4DaV8yF8--
