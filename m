From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND support
Date: Sat, 17 Jan 2004 12:33:58 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040117113358.GL18505@obroa-skai.de.gnumonks.org>
References: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi> <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n83H03bbH672hrlY"
Cc: vnuorval@tcs.hut.fi, netfilter-devel@lists.netfilter.org,
	davem@redhat.com, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--n83H03bbH672hrlY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 14, 2004 at 09:04:27PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:
> In article <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi> (at Wed, 1=
4 Jan 2004 13:25:42 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>=20
> > the packets for local processing. I think the cleanest solution for this
> > is a netfilter module (which I have incidentally written already :)
>=20
> I don't think so. Proxy should not depend on netfilter.

Where is the problem?  It doesn't depend on hevyweight functions like
iptables/conntrack/whatever... it just depends on the netfilter hooks in
the core network stack (which are very lightweight, compared to what the
rest of the packet filtering subsystem does).

> --yoshfuji

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--n83H03bbH672hrlY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFACR2mXaXGVTD0i/8RAjxcAKCUz7F9XATELlM9CvbDYneOengVugCcDN/b
faCTvYaehxbsPqOFe+WY4JE=
=i7yu
-----END PGP SIGNATURE-----

--n83H03bbH672hrlY--
