From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [Prism54-devel] Re: [PATCH/RFC] set_rates support for prism54
Date: Sun, 15 Aug 2004 19:48:43 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408151949.01351.vkondra@mail.ru>
References: <5.1.0.14.2.20040815145122.00afd708@pop.t-online.de> <200408151910.25641.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1250376.I0hDbYN7QE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Margit Schubert-While <margitsw@t-online.de>,
        prism54-devel@prism54.org, mcgrof@studorgs.rutgers.edu,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200408151910.25641.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1250376.I0hDbYN7QE
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I would not mix rates with modulation and other channel parameters.
It looks better to bind frequency with parameters like modulation, channel=
=20
width (10Mzh narrow channels in japan) etc. , into 'channel' number or=20
(channel,band) tuple.

=46or supported and optional rate, IE (info element) format may be the best=
=20
choice.

On Sunday 15 August 2004 19:10, Denis Vlasenko wrote:
DV> On Sunday 15 August 2004 16:21, Margit Schubert-While wrote:
DV> > I disagree with this.
DV> > We don't need parameter parsing either in the driver or in
DV> > wireless.c.
DV> > There is a perfectly good infrastructure in wireless tools iwpriv.c
DV> > Take a look at around line 375 in iwpriv.c for the
DV> > existing example of IW_PRIV_TYPE_FLOAT.
DV> > This could be adapted for this purpose (IW_PRIV_TYPE_BITRATE ?)
DV> > and (mis)use the iw_freq structure to pass the values and extra info.
DV>
DV> Ok. And then we will need to parse that data into format suitable for
DV> prism54 in prism54 driver, and into format suitable for acx100/acx111
DV> in acx100 driver, etc... Most probably this code will be ugly, because
DV> different hardware have completely different way of setting tx rate.
DV> Even acx100 and acx111 are different, not to say acx100 and prism54.

--nextPart1250376.I0hDbYN7QE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBH5P9qxdj7mhC6o0RAnjkAKCPoHxyhCdZmf97FpiBDzyeG4L7pwCfdEU7
zjSjELq7X8fEydLtAVOWNFw=
=Pqbn
-----END PGP SIGNATURE-----

--nextPart1250376.I0hDbYN7QE--
