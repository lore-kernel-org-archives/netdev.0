From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 13:46:58 +0200
Message-ID: <20050812114658.GB16325@rama.de.gnumonks.org>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WYTEVAkct0FjGQmd"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050811.154204.102613246.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--WYTEVAkct0FjGQmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 11, 2005 at 03:42:04PM -0700, David S. Miller wrote:
> From: Harald Welte <laforge@netfilter.org>
> Date: Thu, 11 Aug 2005 22:03:49 +0200
>=20
> > +struct ipt_connbytes_info
> > +{
> > +	struct {
> > +		u_int64_t from;	/* count to be matched */
> > +		u_int64_t to;	/* count to be matched */
> > +	} count;
> > +	u_int8_t what;		/* ipt_connbytes_what */
> > +	u_int8_t direction;	/* ipt_connbytes_direction */
> > +};
>=20
> Won't work in x86 --> x86_64 compat environments.

jeez, it bites me again (the connbytes match was written some time
ago..) .  I'll try (and actually verify) Andi Kleen's suggested version.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--WYTEVAkct0FjGQmd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/IwyXaXGVTD0i/8RAkagAJ9KPj3dCE7H4fpGzhdJJpZmGOSMiwCgpC3P
k2srJ+NTafnDjtqF4PbAD60=
=uT5v
-----END PGP SIGNATURE-----

--WYTEVAkct0FjGQmd--
