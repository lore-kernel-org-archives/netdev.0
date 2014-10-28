From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2] ssb: Fix Sparse error in main
Date: Tue, 28 Oct 2014 18:40:30 +0100
Message-ID: <20141028184030.3b185979@wiggum>
References: <1412184482-2603-1-git-send-email-pramod.gurav@smartplayin.com>
	<CAMf-jSk4GH=8+Cpk4dCzUhbwoKxMOsJPPrURP5-ktAvqXfhsjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/cVsyLqKlI1T7W3DZl4v2iVv"; protocol="application/pgp-signature"
Cc: Pramod Gurav <pramod.gurav@smartplayin.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Pramod Gurav <pramod.gurav.etc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMf-jSk4GH=8+Cpk4dCzUhbwoKxMOsJPPrURP5-ktAvqXfhsjw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/cVsyLqKlI1T7W3DZl4v2iVv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 28 Oct 2014 22:03:02 +0530
Pramod Gurav <pramod.gurav.etc@gmail.com> wrote:

> Michael had suggested to do away with this function if not being used.
> Good to go?
>=20
> Michale can you provide acked-by?

Yes, this looks good.
Acked-by: Michael B=C3=BCsch <m@bues.ch>

> On Wed, Oct 1, 2014 at 10:58 PM, Pramod Gurav
> <pramod.gurav@smartplayin.com> wrote:
> > This change fixes below sparse error:
> > drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
> > was not declared. Should it be static?
> >
> > Cc: Michael Buesch <m@bues.ch>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
> > ---
> > Changes since v1:
> > Removed the function as it is not called anywhere in the kernel
> > as per suggestion from Michael Buesch.
> >
> >  drivers/ssb/main.c | 19 -------------------
> >  1 file changed, 19 deletions(-)
> >
> > diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> > index 2fead38..1e180c4 100644
> > --- a/drivers/ssb/main.c
> > +++ b/drivers/ssb/main.c
> > @@ -90,25 +90,6 @@ found:
> >  }
> >  #endif /* CONFIG_SSB_PCMCIAHOST */
> >
> > -#ifdef CONFIG_SSB_SDIOHOST
> > -struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func)
> > -{
> > -       struct ssb_bus *bus;
> > -
> > -       ssb_buses_lock();
> > -       list_for_each_entry(bus, &buses, list) {
> > -               if (bus->bustype =3D=3D SSB_BUSTYPE_SDIO &&
> > -                   bus->host_sdio =3D=3D func)
> > -                       goto found;
> > -       }
> > -       bus =3D NULL;
> > -found:
> > -       ssb_buses_unlock();
> > -
> > -       return bus;
> > -}
> > -#endif /* CONFIG_SSB_SDIOHOST */
> > -
> >  int ssb_for_each_bus_call(unsigned long data,
> >                           int (*func)(struct ssb_bus *bus, unsigned lon=
g data))
> >  {

--=20
Michael

--Sig_/cVsyLqKlI1T7W3DZl4v2iVv
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUT9UQAAoJEPUyvh2QjYsOpsUP/1n9tMj1birS8923yJFXc/8h
UmoU2WkwEPGJSeI1GxniZTsuLf6VYrHTuQNTEKqbpANn85pU5cJDR2yMrxdiKgBS
TJ2qel0d/zCbi5+LifbmgQjx6WL+JAYvHvSmnDslZB2SHz1dT0UlHxcgXLVxBDvG
D5cZYQn59rZvL2bJBUByf/gsQTgz9GrQ3kR006ZwI1F2aMNB7JwRICbQj34mV8XS
Von0tVKoJGombwiLDFf+r8y09TUuoAlIu4gpRXeOVW7tXbwgYR/B4x3ZSYL92l6F
Th+g10UtCCowEe/xnEGBmaGVT/TVA2cniUQnzjO81j370OKLDnS/EPgZqb8XIXcv
IwX4lv1Ht/iCiQ22vNWTiCqI4Qv0VrsfiRzrJSKGXYfg5j7834ack5Z8pwxFXfn0
TF6zpZWz/S+G3eGPP6GNh/pwS5nNAWebIdoZ9TYJrkp+MrSLCekpQ5dboX/F1eaB
mTNCy1G7nZ8186ulllxeGlNPelWCKmawvgeKkcnJKyQlOyiHFyHHKXat77XAnodO
PmhRExlnEWNfn8J9vE1HZAyu7XLnle9SvOjrmSEiTOiuqNPAam9bQiq4b0sF6SYo
dUAa2nlay+taYlQBksemkCG0NovCpdJTDOJETZ+vs9S2AnWN2NHB2xkic8K2erur
y1PrU7BJkuQGnruUgfW6
=R37R
-----END PGP SIGNATURE-----

--Sig_/cVsyLqKlI1T7W3DZl4v2iVv--
