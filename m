From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 22:34:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921203404.GA3236@sunbeam.de.gnumonks.org>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org> <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> <20040922.010428.104988024.yoshfuji@linux-ipv6.org> <1095784761.3934.52.camel@tim.rtg.net> <20040921173134.GC12132@wotan.suse.de> <1095789507.3934.69.camel@tim.rtg.net> <20040921181525.GB18938@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: Tim Gardner <timg@tpi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040921181525.GB18938@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 21, 2004 at 08:15:25PM +0200, Andi Kleen wrote:
> On Tue, Sep 21, 2004 at 11:58:27AM -0600, Tim Gardner wrote:
> > On Tue, 2004-09-21 at 11:31, Andi Kleen wrote:
> >=20
> > > But also allows an easy DOS. Someone just has to spoof a lot of conne=
ctions
> > > attempts with the source address of your primary name server or=20
> > > some other important service.
> > >=20
> >=20
> > That is what other iptables rules and filters are for. I get thousands
> > of source address spoofs from my Internet connection every day. Network
> > security is a layered approach.
>=20
> I don't think you can eliminate the problem with more filters.

I agree with Andi, and I think we're just being lazy if we say 'well,
the neighbour cache has this problem, but the solution has to be
manually implemented by the administrator'.

Also, we cannot put complex heuristics code in place, unless we can
prove that it again doesn't provide new possibilitis for DoS.

My personal (simplistic) favourite is still a simple threshold (absolute
value / percentage) for incomplete neighbour entries. This way we make
sure that we cannot starve 'real' (fully resolved) entries at the cost
of incomplete ones.

> -Andi

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUJA8XaXGVTD0i/8RAuWdAJwP29sfuwAMjEDkYQ6BMCj0J/+Y4gCfQvBB
vq47lhzPY+1MaCBVgX6xgR0=
=WPtw
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--
