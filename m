From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 23:55:56 +0000
Message-ID: <1264722956.373.561.camel@localhost>
References: <20100128075633.GA4785@serverengines.com>
	 <1264718429.373.520.camel@localhost> <20100128225114.GA1588@kroah.com>
	 <1264720828.373.552.camel@localhost>  <20100128232829.GA31884@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-BjllkLqKzThJP/7aMwoz"
Cc: Ajit Khaparde <ajitk@serverengines.com>,
	netdev <netdev@vger.kernel.org>, stable-review@kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50507 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753157Ab0A1X71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 18:59:27 -0500
In-Reply-To: <20100128232829.GA31884@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BjllkLqKzThJP/7aMwoz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-28 at 15:28 -0800, Greg KH wrote:
> On Thu, Jan 28, 2010 at 11:20:28PM +0000, Ben Hutchings wrote:
> > On Thu, 2010-01-28 at 14:51 -0800, Greg KH wrote:
> > > On Thu, Jan 28, 2010 at 10:40:29PM +0000, Ben Hutchings wrote:
> > [...]
> > > > Also, you should either send this patch to stable@kernel.org, or NA=
K the
> > > > addition of PCI ids for BladeEngine 3 in 2.6.32.7.
> > >=20
> > > Why?  How does the pci id patch for 2.6.32.7 matter with this change?
> >=20
> > Because it looks like the devices being added won't work without this.
>=20
> Hm, what is "this"?  I seem to have been lost on this thread.

The patch I was replying to
<http://article.gmane.org/gmane.linux.network/150441> changes I/O setup
for be2net to use PCI BAR 0 on the new device whereas it uses BAR 1 on
older devices.

> Care to explain it better?  2.6.32.7 is now out with the pci ids, so if
> I need to add something else for the next .32-stable kernel, please let
> me know.

Well that will be for Ajit to sort out.

Ben.

--=20
Ben Hutchings
You can't have everything.  Where would you put it?

--=-BjllkLqKzThJP/7aMwoz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS2IkB+e/yOyVhhEJAQI7MA/8CBg1Z0y9bjN/zycwhAiIDf+V6JKrSEYv
yvku5yVN5xYOYv79eaLkiinEX7D5JWjVlJNwOF6toFucHRi0DbJOVz/K7Cggqwqw
7nzZ3h3m3YgT3bLFRTGCja8ot6bTRnpb5OCiVF6g/kuQWocJVoehJwS1YYUSsIS7
HAD7UPDq31KecsvwQyXCTCypewlpQtcjWyzsGN84GjaKVgw/tdrzbxmOy1bu/PvD
BNIsBQBCNQHCyLFSOt5SBfVnm1YvITVSNATcBhTRKm9pfU+iQghprQjCuyi3IMsT
Gz0IJfA9flqOmN7t6f/6ipCnsTtPU2YS/mtvKNU59KactRcw0y6DOVZTSWuLLBh5
Ho4vgBH9zCqR5o+wMvVrHAT+pYd8XNaELsPn8iFXLS1EuKzBlebcYjFsjamGb4ep
wdD+YlWuM17t5S/44G/r58UgG6iPFFPAaihTCviDpjKZBDtbF4xNIEFpyDzuZX4c
IBIfc7XyVa6gQz5yBaAUs3Whh116awAWigGk8b/j4PPnKCKO8tF0yfu6XiMos1SY
knuioi/6rs9v32QXnHausMIS8HE4k56pfp1sXfKtTxIKp7zJmnFC8Hlg6TzSuxkF
kom/2/mb6pXv9Vil/CwQ85XBEWiQOuTSQk+3hUVHn/tViWEsgXtdMidKl8liKxyw
rS3O8jGgIJQ=
=C6bb
-----END PGP SIGNATURE-----

--=-BjllkLqKzThJP/7aMwoz--
