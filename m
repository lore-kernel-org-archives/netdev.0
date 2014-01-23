From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS hash
 key.
Date: Thu, 23 Jan 2014 05:42:36 +0000
Message-ID: <1390455756.3651.139.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8D4@CMEXMB1.ad.emulex.com>
	 <1390156549.16433.119.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C38B@CMEXMB1.ad.emulex.com>
	 <1390225398.3651.86.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84CF8C@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9Eike+MChYTTkmYTTztU"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42808 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751872AbaAWFmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:42:38 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C84CF8C@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9Eike+MChYTTkmYTTztU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-22 at 12:06 +0000, Venkata Duvvuru wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Monday, January 20, 2014 7:13 PM
> > To: Venkata Duvvuru
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS =
hash
> > key.
> >=20
> > On Mon, 2014-01-20 at 13:28 +0000, Venkata Duvvuru wrote:
> > > Ben, Please ignore my previous reply. My reply options were screwed u=
p in
> > that.
> > >
> > > > -----Original Message-----
> > > > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > > > Sent: Monday, January 20, 2014 12:06 AM
> > > > To: Venkata Duvvuru
> > > > Cc: netdev@vger.kernel.org
> > > > Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable
> > > > RSS hash key.
> > > >
> > > > On Fri, 2014-01-17 at 13:02 +0000, Venkata Duvvuru wrote:
> > > > > This ethtool patch will primarily implement the parser for the
> > > > > options
> > > > provided by the user for set and get hashkey before invoking the io=
ctl.
> > > > > This patch also has Ethtool man page changes which describes the
> > > > > Usage of
> > > > set and get hashkey options.
> > > >
> > > > I'd prefer to have this combined with the -x/-X options (and add ne=
w
> > > > long options to reflect that they cover the key as well).
> > >
> > > if we add hashkey options to the existing -x/-X (--show-rxfh-indir/ -=
-set-
> > rxfh-indir), I think it won't be appropriate going by the command name.
> > > We could change the command name to something like --show-rssconfig /=
-
> > -rss-config but I'm afraid would that be backward compatible?
> > [...]
> >=20
> > That's why I said 'add new long options'.  The ethtool argument parser =
allows
> > arbitrarily many aliases for each sub-command.
>=20
> Just to make sure that we are in sync
>         { "-x|--show-rxfh-indir|--show-hashkey", 1, do_getrssconfig,
>           "Show RSS configuration" },
>=20
>         { "-X|--set-rxfh-indir|--hashkey", 1, do_setrssconfig,
>           "Set RSS configuration",
>           "             equal N | weight W0 W1 ...\n"
>           "             hkey %x:%x:%x:%x:%x:....:%x\n" },
>=20
> And equal/weight will be mutually exclusive with hkey.
> Does it makes sense?

No, you should be able to set both the key and the indirection table at
once.  And the new aliases should then be something like --set-rxfh and
--show-rxfh.

Ben.

--=20
Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-9Eike+MChYTTkmYTTztU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuCrzOe/yOyVhhEJAQoFAA//dSY+hLMAaeh5+gWwjbTsrV9pukHdz6zc
JMYWDZfbGc5cZV6gTXHGWwS5FB0vN0rE7FiZkUQGIXT0xZSj5nUgi7HSG3L9Vzyy
BIdagUWFjPHRaWkoG5JtHOF42601zmlUSGG9j5IU0ff5lSFGRxxfLzqnmUlaqLD+
Ut205DB+XlLesEgcNyfudJS7r3EPDjp677RgEtkCsWM2eCqAlbzWjkj2IrZc5h/v
HzneGUkaKaQPxS2AvR62U7l++ZFtP5t74q2IDVg54YO7cnhot6q/pavrxmyRacco
iBLZleqG9tsaCmdT0FuuvUv3nkv2aEoG0Sgbh7XowyAXXNP79VZrTUyec2CGaIhW
RYQH4OdQORg192daUKh4+lizcZVlJsploLUvLb5dIH0ClNwBOS+dqqCQ+7JQUDGA
n7qzsgtBM/4MkhRjA6Qn1BNafD6le6n80HHirf3f+6sg+lMUa8uDTUlxYvTHtkcx
E2Lg8QVpsuIBtcIoSUps8rDlO3zqLRTyMb0BhgDCQFlWkxEnZkdz9oysjWM8w5MD
qu+QRr5jInUJ5myLRbHmgSmY0FJTe3ZGikzTOw0w6L7HIm8B5gChlYo6MCtgR/wi
tDANnFFYtbVfl3meLib+vtwiQdsT1+oay0e39g8tvLN/EqS0lSD4Vu3PrrobLBme
ihEjREH1yYk=
=stxv
-----END PGP SIGNATURE-----

--=-9Eike+MChYTTkmYTTztU--
