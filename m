From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target, seq_file version
Date: Thu, 21 Oct 2004 20:03:24 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021180324.GL3551@sunbeam.de.gnumonks.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
	<20041021163655.GK3551@sunbeam.de.gnumonks.org>
	<1098380650.1031.82.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="A2x6GFCQWVc4i5ud"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1098380650.1031.82.camel@jzny.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--A2x6GFCQWVc4i5ud
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 01:44:11PM -0400, jamal wrote:
>=20
> Sorry, couldnt resist - so out of hiding for just a few seconds; should
> be able to achieve this much simpler with gact.

One of the issues that CLUSTERIP needed to do is to work with
locally-originated connections, i.e. every node within the cluster still
has to be able to open tcp connections to anywhere.

We currently catch this with connection tracking, which will assign all
reply packets to such outbound connections INVALID on all but the
originating node in the cluster.

Yes, I know, this sounds like a very strange setup.  Still it was one of
the requirements for it's implementation.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--A2x6GFCQWVc4i5ud
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd/nsXaXGVTD0i/8RAtsdAJ9wpvL5dCeNxqsj7+6DisrSS4JSfgCfUY4w
qn2cFMew7dFBjw8GAqvnz9Y=
=XKDz
-----END PGP SIGNATURE-----

--A2x6GFCQWVc4i5ud--
