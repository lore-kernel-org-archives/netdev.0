From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 20:15:37 +0100
Message-ID: <1265829337.19075.0.camel@jlt3.sipsolutions.net>
References: <20100210185816.GB3286@tuxdriver.com>
	 <20100210.110756.201335073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-vLMSKYiJRxC2PtVe1Vmm"
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100210.110756.201335073.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vLMSKYiJRxC2PtVe1Vmm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-02-10 at 11:07 -0800, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 10 Feb 2010 13:58:16 -0500
>=20
> > Please let me know if there are problems!
>=20
> I see one:
>=20
> > diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> > index 5681ebe..03dfd27 100644
> > --- a/drivers/ssb/main.c
> > +++ b/drivers/ssb/main.c
> > @@ -494,8 +494,7 @@ static int ssb_devices_register(struct ssb_bus
> *bus)
> >  #endif
> >  			break;
> >  		case SSB_BUSTYPE_SDIO:
> > -#ifdef CONFIG_SSB_SDIO
> > -			sdev->irq =3D bus->host_sdio->dev.irq;
> > +#ifdef CONFIG_SSB_SDIOHOST
> >  			dev->parent =3D &bus->host_sdio->dev;
> >  #endif
> >  			break;
>=20
> The commit message says "fix a typo" but it's also removing
> the assignment of sdev->irq
>=20
> All the bus types assign the sdev->irq, so it looks like
> this was removed unintentionally.
>=20
> If it was intentional, it needs to be explained in the
> commit message or a code comment.

It was intentional -- that sdev doesn't even have an irq member, but
nobody ever noticed because of the wrong ifdef.

johannes

--=-vLMSKYiJRxC2PtVe1Vmm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLcwXWAAoJEODzc/N7+QmafZkP/24lJ7YUTpZ91YLi4nRistUd
DDKwfpScPBKO6EOHzWB1ms6fjS9XVSHJM7P4AwPyHFHOowjjoZkc5EBB6TW4EyB5
KmK57mRsrcJGlBYD207KuwS3K+FOlA0kzJRX/ZwBPDV7/bxpVxObgwazVUWA4Soc
B3/1AW+RVWQPMJHgXzyZ8jIUCmGMIwSn1ebHc3sUSKox4VjhPbyhcDryTHHaC0RP
WQYJ3oQa3PjQQwT1WoVcf2CoQrKU2QxbmWrP9QGPMIek9DqiZvEKEbb203gG0iYe
NuT84VZzEbZNo+1289XnktTQ6OFBumRhumBjOE1hmz+oIhl/3cTSnmU3WAHcGSe4
hn6UDhWPzuEE7nLP0GRfIFutrAqGM+Fs9yQmpcWJwfq7XYyRDcCe+i5tsd0UUElq
6095z+J3pDdmUz2JbEu3ahlziqPKUTCspPCyQe3rvy7UslIwB87yjpL4Mm3E+epa
CFkWVfSVRkr2DELv29Y0OJz1pGincH6V3X3fzKcPkrWOmsRu2q10tCkZdrhHxjQ5
eT48Jjwf9Qlv+dAbVmAKON+7K+n45Yr/52N6TneVxa958u4R+COS1Q/peOyyl3mG
O2SE0OTJmdWRDLG6VGRGvmc6aOsj7xeJ31KtYWukdjc+oUHHQCqpknXrepD/WlU0
HC5N5TOMVmfHxLKyJngW
=MjwG
-----END PGP SIGNATURE-----

--=-vLMSKYiJRxC2PtVe1Vmm--
