From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Tue, 31 Aug 2004 18:48:48 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408311848.55628.vkondra@mail.ru>
References: <20040830045441.GA7415@jm.kir.nu> <20040831085458.GD31207@ruslug.rutgers.edu> <1093966225.1464.9.camel@rootix>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1097049.0dEAopxo3L";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pedro Ramalhais <ramalhais@serrado.net>,
        "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik <jgarzik@pobox.com>, jt@hpl.hp.com,
        Jouni Malinen <jkmaline@cc.hut.fi>, hostap@shmoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1093966225.1464.9.camel@rootix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1097049.0dEAopxo3L
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 31 August 2004 18:33, Pedro Ramalhais wrote:
PR> > > Intel Centrino driver is re-using chunks of HostAP, and I'm looking
 at PR> > > doing so for the RealTek 8180 driver I am about to publish.
PR> >
PR> > Can someone elaborate on what "chunks" the centrino driver is using
PR> > from hostap?
PR> >
PR> > Jeff what aspects are you looking to re-use from hostap?
PR> >
PR> > I guess we at prism54 should also see what we can re-use too then.
PR> > Our next driver (a softmac driver) will have a lot more code since the
PR> > MAC will need to be implemented on the driver side -- I'm not yet sure
PR> > of the exact details as I haven't grep'd through the available code y=
et
PR> > I'm wondering though -- are there any other softmac drivers out there,
PR> > or to come soon?
PR> >
PR> >  Luis
PR>
PR> The ipw2100 driver and ipw2200 driver both use these parts of hostap
PR> code:
PR> RX code (i think now it's in file hostap_80211_rx.c)
PR> little parts of the TX code (hostap_80211_tx.c)
PR> the hostap_crypt* code for WEP.
PR> Some IEEE802.11 related parts of header files.
PR> The ipw2100 is beggining to use hostap_crypt_tkip and hostap_crypt_ccmp
PR> for WPA and WPA2.
PR>
PR> I think that's it. Better ask James Ketrenos, he is one of the
PR> developers at intel.

Luis,
please correct me if I'm wrong. It seems to me that softmac drivers will ne=
ed=20
significant changes relative to the model that HostAP employ. Also, many=20
changes dictated by QoS (TGe), if one want to really implement it. Will you=
r=20
product support TGe?
May be, we need to do design for generic "softmac" that will be then used w=
ith=20
different PHY's. Question is, whether we can formally describe boundary=20
between softmac and PHY.
I am interesting in joining this "softmac" development, as I will do some=20
other .11 card which is "softmac". Can't reveal details yet, but we may=20
discuss softmac issues without disclosing private info (I don't want to los=
e=20
my job).

Vladimir.

--nextPart1097049.0dEAopxo3L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBNJ3nqxdj7mhC6o0RAvDDAKCRVT+zjNIJ8HNXu0ki/3OyLYke7gCePtm3
iffIl4s2WbJkiqD/jKTZSC4=
=df+R
-----END PGP SIGNATURE-----

--nextPart1097049.0dEAopxo3L--
