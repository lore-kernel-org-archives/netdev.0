From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters defrag per netns
Date: Wed, 4 Jan 2012 22:15:10 +0100
Message-ID: <201201042215.20290.hans@schillstrom.com>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <201201041248.36881.hans.schillstrom@ericsson.com> <20120104174035.GB3489@1984>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2694023.bmYndUduOG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120104174035.GB3489@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2694023.bmYndUduOG
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello Again

On Wednesday, January 04, 2012 18:40:35 Pablo Neira Ayuso wrote:
> On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> > I like that idea, an "early" table at prio -500 with PREROUTING.
> > There is also a need for a new flag "--allfrags"
> > i.e. all fragments needs to be sorted out and sent to same dest for def=
rag.
> >=20
> > ex.
> > iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK
>=20
> New tables add too much overhead. We have discussed this before with
> Patrick.
>=20
Only if loaded ..=20
It would have been the perfect solution.
Is the discussion about the overhead on the list (I can't find it)?

I made a quick test with an "early" table
and --allfrags fix (for IPv4) and it works really good.

iptables -t early -A PREROUTING -i eth0 -a -j NOTRACK
iptables -t mangle -A PREROUTING -i eth0 -a -j HMARK --mod 3 --offs 100

So your opinion is no more tables,
even if it's rare that it is loaded?

Regards
Hans

--nextPart2694023.bmYndUduOG
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAk8EwWgACgkQsPw1jACzjGZZkwCcCWx6T4rBkmfJCnSaU0CtFxYk
o+AAnRvAkWg3e32ua2oWi/5VaonoMM0p
=Ked8
-----END PGP SIGNATURE-----

--nextPart2694023.bmYndUduOG--
