From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [Prism54-devel] Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 21:41:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408152141.48877.vkondra@mail.ru>
References: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de> <200408151949.01351.vkondra@mail.ru> <200408152012.18018.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart13660570.kJMNPqysdf";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Margit Schubert-While <margitsw@t-online.de>,
        prism54-devel@prism54.org, mcgrof@studorgs.rutgers.edu,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200408152012.18018.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart13660570.kJMNPqysdf
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

DV> > For supported and optional rate, IE (info element) format may be the
 best DV> > choice.
DV>
DV> I did not quite understand you, can you elaborate a bit?

How card know what rates it can use? It parses "supported rates" IE (info=20
element) from beacon it gets from AP. My point, it is reasonable to use the=
=20
same language to specify further restrictions. This way, we will speak the=
=20
same language as standard do.

In standard, there is no way to say "you can use PBCC, but not for rate 5.5=
".=20
PBCC is either permitted or not. For "good" hardware, there is no point of=
=20
doing this. You may need to artificially restrict rate/modulation only if=20
hardware can't find best for current channel conditions, or, of course, for=
=20
debug. But, I would say, for this cases, let's use debug hooks. Mainline=20
should be as close to standard as possible.

It should be as generic as possible, also. Scheme you suggested is not very=
=20
scalable. Think of TGn that would for sure add its tricks with modulation. =
If=20
we start combining rate with modulation, we will shortly fall into too many=
=20
options.

Does it clarify my point?

--nextPart13660570.kJMNPqysdf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBH65sqxdj7mhC6o0RAi2oAJ0SUm8JiqR9pAAO0eZKM0+5UfHysQCfW+P1
nDQusW70c6m3S80KD2O6RUU=
=/shC
-----END PGP SIGNATURE-----

--nextPart13660570.kJMNPqysdf--
