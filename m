From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 15:03:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021130327.GD3551@sunbeam.de.gnumonks.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org> <20041021075530.GA1278@infradead.org> <20041021091229.GA3551@sunbeam.de.gnumonks.org> <20041021110513.GA21579@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E13BgyNx05feLLmH"
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, Christoph Hellwig <hch@infradead.org>,
        Linux Netdev List <netdev@oss.sgi.com>, lmb@suse.de
Content-Disposition: inline
In-Reply-To: <20041021110513.GA21579@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--E13BgyNx05feLLmH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 01:05:13PM +0200, bert hubert wrote:
> Is the CLUSTERIP target going anywhere after the (needlessly harsh) rebuk=
es
> posted here?

Yes, I think so.  I'm in the process of investigating why I didn't use
seq_file at the time I implemented it (some 1.5 years ago, IIRC).
Unfortunately I don't really remember all the issues involved :(  If I'm
not mistaken, I even posted some questions in this regard to lkml.

> I note with glee that CLUSTERIP implements (and improves) the evil ideas =
of
> http://lartc.org/autoloadbalance.php3

I didn't know about that page, but yes, indeed.  I first was informed
about this approach by Fabio Olive Leite, who was one of my colleagues
at Conectiva (where I was 2001).  He presented this approach at the
Linux Kongress 2002:
http://www.linux-kongress.org/2002/papers/lk2002-leite.html

Later SuSE approached me if I was interested in implementing that idea,
and that's how CLUSTERIP happened.  If I'm not mistaken SuSE is already
shipping this (at least in some beta version?) - I don't really know but
maybe lmb can shed some light on this issue.

> And yes, I've received hate mail over this from switch engineers :-)

Why is that?  They have to deal with multicast traffic, too...  and I
don't really see how this is any different.

> Good luck!

Thanks ;)

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--E13BgyNx05feLLmH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd7OfXaXGVTD0i/8RAhULAKCbEQOzqKpOR7hgFhmS+Fyk3NrBmwCdFFNF
TYuiW0FOhUACwSintzs+BZk=
=umYQ
-----END PGP SIGNATURE-----

--E13BgyNx05feLLmH--
