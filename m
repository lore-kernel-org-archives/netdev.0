From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [patch v2 01/11] DM9000: Remove the 2 resources probe scheme.
Date: Mon, 23 Jun 2008 09:40:12 +0200
Message-ID: <200806230940.16343.laurentp@cse-semaphore.com>
References: <20080622201645.041001353@fluff.org.uk> <20080622203417.GA4050@solarflare.com> <20080622211811.GC26276@fluff.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart17350488.aJSqfdApGA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	jeff@garzik.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:52743 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751953AbYFWHkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 03:40:19 -0400
In-Reply-To: <20080622211811.GC26276@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart17350488.aJSqfdApGA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 22 June 2008 23:18, Ben Dooks wrote:
> On Sun, Jun 22, 2008 at 09:34:18PM +0100, Ben Hutchings wrote:
> > Ben Dooks wrote:
> > > From: Laurent Pinchart <laurentp@cse-semaphore.com>
> > >=20
> > > The dm9000 driver accepts either 2 or 3 resources to describe the pla=
tform
> > > devices. The 2 resources case abuses the ioresource mechanism by pass=
ing
> > > ioremap()ed memory through the platform device resources. This patch =
removes
> > > that case and converts boards that were using it to the 3 resources s=
cheme.
> > >=20
> > > Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> > > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > > ---
> > >=20
> > > diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> > > index 6bc8924..fca7831 100644
> > > --- a/drivers/net/dm9000.c
> > > +++ b/drivers/net/dm9000.c
> > > @@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
> > >  	struct board_info *db;	/* Point a board information structure */
> > >  	struct net_device *ndev;
> > >  	const unsigned char *mac_src;
> > > -	unsigned long base;
> > >  	int ret =3D 0;
> > >  	int iosize;
> > >  	int i;
> > > @@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
> > >  	if (pdev->num_resources < 2) {
> > >  		ret =3D -ENODEV;
> > >  		goto out;
> > [...]
> >=20
> > So shouldn't "< 2" be changed to "!=3D 3"?
>=20
> Hmm, I'll edit laurent's patch and re-send, assuming it's alright with
> him.

That's alright with me.

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart17350488.aJSqfdApGA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIX1Ng8y9gWxC9vpcRAm05AKC0lKwCfx42aAOZJvBzeZHsyw4YNwCffRDj
TjHeaUYUzwThozQrVeyjRCI=
=Lbva
-----END PGP SIGNATURE-----

--nextPart17350488.aJSqfdApGA--
