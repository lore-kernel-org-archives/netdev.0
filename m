From: "maxime.ripard" <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: Re: [PATCH 02/10] net: stmmac: Honor DT parameter
 to force DMA store and forward mode
Date: Tue, 10 Dec 2013 21:10:22 +0100
Message-ID: <20131210201022.GE3651@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <CAGb2v67ZNtbQm+ZW5v_3wNbz1=oLhXks6gbTSjLYa=Nnoz8w-A@mail.gmail.com>
 <20131207100737.GI24519@lukather>
 <2994980.boLDbkkER8@flatron>
 <CAGb2v64BMNjbbc7j2XesuPEXZV+RnjtP1sAPQ4icU=-wjh3YNQ@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fWddYNRDgTk9wQGZ"
Cc: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"rob.herring" <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBRXMTWKQKGQEY6FTQNI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v64BMNjbbc7j2XesuPEXZV+RnjtP1sAPQ4icU=-wjh3YNQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--fWddYNRDgTk9wQGZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 09, 2013 at 10:59:38AM +0800, Chen-Yu Tsai wrote:
> On Sat, Dec 7, 2013 at 7:06 PM, Tomasz Figa <tomasz.figa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Saturday 07 of December 2013 11:07:37 maxime.ripard wrote:
> >> On Sat, Dec 07, 2013 at 09:23:27AM +0800, Chen-Yu Tsai wrote:
> >> > Point taken. The current implementation will override settings passe=
d from
> >> > platform data. ORing the two would be better.
> >>
> >> Platform_data and DT-based configuration are pretty unlikely to be
> >> used together, so ORing it doesn't have much sense.
> >
> > In fact, the recommended way is to always use platform data alone if it=
 is
> > present or try to parse DT otherwise, so no mixing of data from these t=
wo
> > sources should be done.
>=20
> Would binding platform data with compatibles, as I did so in this patch
> series, be a bad idea then?

What I meant was that you'll either be probed will pdev->dev.of_node
or pdev->dev.platform_data filled, but not both at the same time, so
ORing it isn't really sensible.

But I don't see why you couldn't reuse the stmmac_platform_data
structure in your patch.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--fWddYNRDgTk9wQGZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSp3UuAAoJEBx+YmzsjxAgFpUQALmnbKSdGnMDFHC7P7U9mpkN
Ni/XAfEGW26cgaHRMsbfnWl1/PK49Y3a4oV4CeXP1Ppizx3FFIcLOIMzIQ7v1W+P
nmBKa6vQ5vd+dR3y+5ieoAKWfduVwLHcYFLwp5Je3mtihJcA4Vzg7Dn6i0pUJwVc
mase7vou7HO4dKWBPcjNwU5RPpiCEkfKVEfTwWI0Eqf+JrFJiMiDLl6lpbcLfJWV
4mE+L+i9Y7jkoeKTrMbNhvkb9m2Sr9xe6537qP6x2wZvK0JCypnjVBFZ8mXqRmHy
SkmBWnwvtGT3N7YwCIqzv5ko6AS+lgaO1y2Q5NcKf9dtTPN45foDrmbaQwv/3udB
Z9udO41pQdujcGf5kl4ktPhr2RcT3ALEmzSTx897HSmX5s8vh55qBVY2uqY9O2db
Wbi6th30PvfodehYe67zll8V8XAVIyRMKcatZ/CAOmqTeJvh8ZI+gDOUBlUSHPOK
Bpz7aZpSEraEBDyhqXC7q245kXpRueHEeKLRTU1cwXnfvxfXiHl7mbKNeTzBzrbd
UHznK6KILPgW4VoVsrGHxiiovmcJwV6LQG5BnoyQOlXSKJXL6slDCe+cbdro11TZ
ImpKFZQKvM8cVsn+nwTKpEi+OKS6E9/BCotcgYQ9ejTNKZA8GTa831bPTaXxbRVc
3cNfzO3k/lBFUe5UVnyg
=mL1q
-----END PGP SIGNATURE-----

--fWddYNRDgTk9wQGZ--
