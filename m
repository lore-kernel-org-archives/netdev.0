From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Mon, 25 Feb 2008 11:13:56 +0100
Message-ID: <1203934436.13162.64.camel@johannes.berg>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc>
	 <47C0815F.7020100@pobox.com> (sfid-20080223_202627_127192_27742B3F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FYQvIP/8bOtG/Jft4kRc"
Cc: Sebastian Siewior <netdev@ml.breakpoint.cc>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42232 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbYBYKRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 05:17:48 -0500
In-Reply-To: <47C0815F.7020100@pobox.com> (sfid-20080223_202627_127192_27742B3F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FYQvIP/8bOtG/Jft4kRc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sat, 2008-02-23 at 15:26 -0500, Jeff Garzik wrote:
> Sebastian Siewior wrote:
> > so select it.
> > Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
> > ---
> >  drivers/net/Kconfig |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index f337800..a116056 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2363,6 +2363,7 @@ config GELIC_NET
> >  config GELIC_WIRELESS
> >         bool "PS3 Wireless support"
> >         depends on GELIC_NET
> > +       select MAC80211

That seems completely wrong since it's a full-mac "chip" (implemented in
the HV or so maybe). What exactly does it need from mac80211?

johannes

--=-FYQvIP/8bOtG/Jft4kRc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8KU46Vg1VMiehFYAQIK8Q//duMRuVHKhbihtyrKEqrQS392vf4bxEkO
0vp0FioSSRUFntJtCda/qpdqS35oGw/nS7RwAezS5HVFL0CCHMZyEn3YY5zTjlEQ
Li3CJ48IuAoFIvaYzMjhfmrZOoao7CV+immGVRYdPYAP7T3xdb9za4P55inHMq+m
eQiZyaLTy+ligE5iSnftRGaO3hAJynxaRAj5fqKYqEHmf0StQuDJqb3mRZKHtftS
7/fhmFWfV0YY7SAlgi3KYFyV6/efzw5nTDWOIUaya8s5s2LuOHlN8ovaQ7Dq0Bdb
vQVGBOYtKLOfYi75scKuqCDFH8gl/NQ3f9IFhDX7tj1anO7wCfrNUS8MoVgH31y0
521Ry6OoygNlcA9GzukfsKkZuFzCfMMFize7grG1mxItNJC2ybyNDgb9ZWY6jKhd
ytA9OoZzxuY5EJOLeOxCaTbXUTas6i4msFzgNz/u4rkVlN/ZDlKIXc7B6l49NQD5
1CrDV3gAcKrab13K3hr5mA1rw8krXzkzjnFoGEAhorGcIQ3550CuAkwLZbK67W7R
Sx2OWE/1J5nsACYQ6gnm6gXpOAZ5zeH7z9+tPdpJzsllnNdOVKDfrcGzrqQMwlLs
OQA840O8pT4GtbaqXs7qML04ECWDwRuzal1le8qzXDn//MPguCRxc3jlzgFWuV+8
1c9OswwqDa4=
=dtWH
-----END PGP SIGNATURE-----

--=-FYQvIP/8bOtG/Jft4kRc--

