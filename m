From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 22:54:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409072254.18804.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409072141.58893.vkondra@mail.ru> <20040907121019.733cc7aa.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2008819.eKJUJ3LL4V";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Sam Leffler <sam@errno.com>,
        Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040907121019.733cc7aa.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2008819.eKJUJ3LL4V
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

DS> > This should be done in generic way. This information used to
 communicate DS> > berween particular driver and generic stack. For example,
 Rx PHY info and Tx DS> > status info should be used for in-stack generic
 rate scaling algorithm. DS> >
DS> > To complicate it a bit, cb[] is only 48 bytes long. PHY info may easi=
ly
 exceed DS> > this size, so it's better to allocate something and free it in
 destructor. DS> >
DS> > But again, point is this structure should be generic since it is used
 by DS> > stack.
DS>
DS> TCP does the same thing, and if space is an issue you can use
DS> pointers in the cb[] area, other subsystems do this.

Sure, I agree. But this structure for PHY should be defined in stack, it is=
=20
not driver's decision.

Actually, I'd like to fit this stack into real life.

To get real, I want, for some wireless card, write driver that will be able=
 to=20
Tx/Rx 802.11 frames, and let stack handle the rest. Like association,=20
roaming... What should be done to get to this stage?

Jeff, your opinion on this?

Sam (you represent Atheros?), would you like to cooperate to make this=20
possible?

Anyone doing drivers for Intersil and Broadcom, are you on this list? Would=
=20
you join this effort?

--nextPart2008819.eKJUJ3LL4V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBPhHqqxdj7mhC6o0RAvh1AKCG4t+46iEN4rezX3GPNbSSLGs0JgCgkHAp
/Kb6ZYVrwnMoV1LrnwD57xI=
=JkRX
-----END PGP SIGNATURE-----

--nextPart2008819.eKJUJ3LL4V--
