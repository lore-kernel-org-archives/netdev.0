From: Harald Welte <laforge@netfilter.org>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 19:00:40 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040819170040.GW3921@sunbeam.de.gnumonks.org>
References: <200408190721.QAA02944@toshiba.co.jp> <20040819094401.GY3921@sunbeam.de.gnumonks.org> <20040819071750.67f0e924.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NgVbDbWK8YZhIM7w"
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net,
	kadlec@blackhole.kfki.hu, kisza@securityaudit.hu,
	netfilter-devel@lists.netfilter.org, usagi-core@linux-ipv6.org,
	netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040819071750.67f0e924.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--NgVbDbWK8YZhIM7w
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 19, 2004 at 07:17:50AM -0700, David S. Miller wrote:
> On Thu, 19 Aug 2004 11:44:01 +0200
> Harald Welte <laforge@netfilter.org> wrote:
>=20
> > http://lists.netfilter.org/pipermail/netfilter-devel/2004-August/016277=
=2Ehtml
>=20
> I totally disagree with this change.

Ok, that's fine with me.   Let's stay with the skb_header_pointer(),
which by the way [as expected] is not visible on my profile runs.

Still, I am curious to know if anyone on one of the Cc'ed mailinglists
can imagine a case where parts of the header up and including the tcp
options could be non-linear.

And no, I do not want to know this in order to say that
skb_heder_pointer() is bad.  I just want to know, because then we might
still need some magic for those cases in order to avoid a case where we
end up with per-rule copies or similar stuff again.

Thanks!

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--NgVbDbWK8YZhIM7w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBJNy4XaXGVTD0i/8RAhmdAJ0Q9BYtbHuvWy/d8aUx2kgnaZv6nACgrvDy
Cn9ugff7nwiPePoEsXcDNCY=
=e4bT
-----END PGP SIGNATURE-----

--NgVbDbWK8YZhIM7w--
