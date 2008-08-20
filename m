From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Wed, 20 Aug 2008 20:44:49 +0200
Message-ID: <1219257889.3502.13.camel@johannes.berg>
References: <s5h3akzwtki.wl%tiwai@suse.de>
	 <1219252617.7591.350.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JUz9NAurQ+0t9jJ9Kemi"
Cc: Takashi Iwai <tiwai@suse.de>, linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1219252617.7591.350.camel@violet.holtmann.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JUz9NAurQ+0t9jJ9Kemi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-08-20 at 19:16 +0200, Marcel Holtmann wrote:
> Hi guys,
>=20
> > I found that CONFIG_KMOD was already removed in linux-next tree.
> > This seems to result in many breakages.  For example, I cannot mount a
> > FAT device automatically because of failure of automatic loading of
> > nls modules.
> >=20
> > My particular problem would be fixed by the patch below, but I found
> > CONFIG_KMOD is still referred in many places.
>=20
> I am happy to fix the net/bluetooth/ part, you someone has to put out a
> guideline how this should be fixed.

Bluetooth was already part of http://lkml.org/lkml/2008/7/9/144

Basically, I got rid of CONFIG_KMOD, always enabling it when
CONFIG_MODULES is defined and making it a dummy no-op inline when not.

johannes

--=-JUz9NAurQ+0t9jJ9Kemi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIrGYeAAoJEKVg1VMiehFYT5QP/1Q3lUrurxSO2lEmWPa8eCiU
3WbXzKXQRrseZh2O1fJd/rrhxEjvmNntlTfXTra+3L0jox1uV12D2t+6LQMiuS4g
2+mf0yJlEiTeCvEWb3ts8xA8/ryE/yuL/LdF3nvz1lLspju1S9h/4X9fnqT5lIVC
p788yhXDRUOjJoIl4eEtuw/KIAxkPKnyp1Xo3WBGBAMw3vBvXwyHbFzvitWsaKdd
KFGQGISY3l1dkazIKcfUApbZBegYtJEpTeLoHnZRzJH5bWGkIoe/iCjZylyBXTY+
LvwLyoYRwHz2wT8wbJ4Vmz1eYanS4yIBDsE1ZSguuQUaYGyrGaHUtXCShMvTYYUP
vo1cif1jt/66A3mgNWcnEu+ZmAMAmP4mz/O8ltUDsHwjVxIRk681zV/8UtO8Q/sW
22fAlvPiFfRQhoCjfJLBJKZNfeQfNWGynPu5eVk5WvQlPIE9wvVcw5HYf8OoAsog
82F+8Np9Fh2zHWxtzae6SsQhUrvQVJmUT1gasY3z7rOgFCF53Mo6pNiX1x574zQ4
hUXnZWyguBDnXOMSc1PnXirpgfZ/GVo+E/fCnFJ8QRFsBbx7JNLLkNDt7K9QNRNc
R+fMJUXik8cB4ERKY4uGOTMxbBsmAOwEvPk7XY9mdxDe0LCRDRHDdNS6ki+t8aat
PxyoRvxb8pavE9Svj83V
=1Fjh
-----END PGP SIGNATURE-----

--=-JUz9NAurQ+0t9jJ9Kemi--
