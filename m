From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Fri, 20 Aug 2004 12:59:56 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820185956.GV8967@schnapps.adilger.int>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net> <20040820175952.GI5806@certainkey.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="o0y1lerN6xYE2ROn"
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Luc Cooke <jlcooke@certainkey.com>
Content-Disposition: inline
In-Reply-To: <20040820175952.GI5806@certainkey.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--o0y1lerN6xYE2ROn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 20, 2004  13:59 -0400, Jean-Luc Cooke wrote:
> Is there a reason why get_random_bytes() is unsuitable?
>=20
> Keeping the number of PRNGs in the kernel to a minimum should a goal we c=
an
> all share.

For some uses a decent PRNG is enough, and the overhead of get_random_bytes=
()
is much too high.  We've needed something like this for a long time (someth=
ing
that gives decenly uniform numbers) and hacks to use useconds/cycles/etc do
not cut it.  I for one welcome a simple in-kernel interface to
e.g. get_urandom_bytes() (or net_random() as this is maybe inappropriately
called) that is only pseudo-random but fast and efficient.

Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://members.shaw.ca/adilger/             http://members.shaw.ca/golinux/


--o0y1lerN6xYE2ROn
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBJkospIg59Q01vtYRAl5VAKCVp4g4/om0QnxQyojGH+LNyAp7kgCfVgWa
f2ociyLHiIpWvcmGR1Lnb7Y=
=xfaR
-----END PGP SIGNATURE-----

--o0y1lerN6xYE2ROn--
