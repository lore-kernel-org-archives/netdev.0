From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Wed, 20 Aug 2008 20:16:05 +0200
Message-ID: <1219256165.3502.10.camel@johannes.berg>
References: <s5h3akzwtki.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vOsB7XUG031uSQfMjjeo"
Cc: linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <s5h3akzwtki.wl%tiwai@suse.de>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vOsB7XUG031uSQfMjjeo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> I found that CONFIG_KMOD was already removed in linux-next tree.
> This seems to result in many breakages.  For example, I cannot mount a
> FAT device automatically because of failure of automatic loading of
> nls modules.

This is odd. I had posted a long series of patches removing all of the
users I had found (similar grep like the one you used), see
http://lkml.org/lkml/2008/7/9/150 for the whole thread.


For some reason, only seven of those eleven patches ended up in the
kernel, you had taken the alsa one and Rusty posted only six of them.

I'd hope that the patches posted at the URL above still apply, and I
sure intended the series to go in as posted with the removal of
CONFIG_KMOD coming last.

johannes

--=-vOsB7XUG031uSQfMjjeo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIrF9hAAoJEKVg1VMiehFYJkkP/2WYDHyk2Z2u1CACt/pU0x/m
gijNKGSaUi8ewe5Z14NGH5Fz5Gmx+OozdxKu6ZHvi9dzld97+57gjwYIpqcrIDTK
2J3zFo6ZnVcpwJUpu1kbbEFQ9rXq3HH88P70eb2j2dPk1ysEO8G5t+awSpnfSHqI
8PEOv2VnJn1xg9H0eWZcC6uKHyYDa+ArVwfVCtLzyeB8GLPUNvB1Th7iTiWB+5Gi
qq4DZM+2k06aSe04HhRyVudWCxNDJu9KepVXo0OyhqpdUA9/M7BcTvLCSHl2CQnF
LPxOb73wnrvEi8jTdo8v2ExefFiDKWx03EO4eaq/MpRGxCHS+jKVlACIEIPDni1M
jJf4/t9u9A71HaXkX9OXpy+pRmn35b24QOiFRTscGxCgZF2UMPZfgvZRZykgSN9p
SmfMesZI6QAffIe0DOIZSoldnRCxC2F/0qypgfm7mSiNURd+aIrZCcBpwfEQahCx
HyknYwJsdhoM5zxRMtdrkarehWy+LehtQL0Z7xJ9SeSP0JB3HDyEpZDxeDlzU8dt
wyo3vLr/+HMvObiNnZToT4VR35742RQrP/hyArlm6JmnYERcFDzVRMVwr9uaGfCU
D2g4gXiR2Zu2ddMp8dSoBg+f2rMd+N6qKeN+J+Lsyja6mIVWc+RuGmIG4SXiCMd0
11XLourY1XfWfY3IiKaF
=9vFx
-----END PGP SIGNATURE-----

--=-vOsB7XUG031uSQfMjjeo--
