From: Harald Welte <laforge@netfilter.org>
Subject: Re: Remote DoS vulnerability in Linux kernel 2.6.x (fwd)
Date: Thu, 1 Jul 2004 11:10:48 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040701091048.GR1410@sunbeam.de.gnumonks.org>
References: <Xine.LNX.4.44.0406301423320.32212-100000@thoron.boston.redhat.com> <Xine.LNX.4.44.0406301507320.32316-100000@thoron.boston.redhat.com> <20040630144230.1d52864b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pWJxWxNlJUNgDlXi"
Cc: James Morris <jmorris@redhat.com>, netfilter-devel@lists.netfilter.org,
	netdev@oss.sgi.com, arjanv@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040630144230.1d52864b.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--pWJxWxNlJUNgDlXi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 30, 2004 at 02:42:30PM -0700, David S. Miller wrote:
=20
> This bug only came up because up the huge change Rusty and Harald did
> to make these modules not access the SKB header data directly, and
> instead to use local on-stack copies and skb_copy_bits().

A change we had to make in order not to assume fully linearized packet
including the tcp header.

I suppose the trivial fix has already been pushed upstream...

Very unfortunate that vendors weren't informed in advance :(

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--pWJxWxNlJUNgDlXi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA49UYXaXGVTD0i/8RAq4sAJ9GVk5gzRKJAiGgtIWalh/ydPTYtACeP6gt
vNB5hX9KKHHjwltrbeQalVo=
=skaj
-----END PGP SIGNATURE-----

--pWJxWxNlJUNgDlXi--
