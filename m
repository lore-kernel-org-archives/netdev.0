From: Andre Noll <maan@tuebingen.mpg.de>
Subject: Re: [net] 34fad54c25: kernel BUG at include/linux/skbuff.h:1935!
Date: Tue, 22 Nov 2016 23:30:35 +0100
Message-ID: <20161122223035.GH19939@tuebingen.mpg.de>
References: <582b7c30.nXQXP2V4/6pFiYwt%xiaolong.ye@intel.com>
 <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="tT3UgwmDxwvOMqfu"
Cc: kernel test robot <xiaolong.ye@intel.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, LKP <lkp@01.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tT3UgwmDxwvOMqfu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 22, 14:04, Linus Torvalds wrote
>  what's the situation on this issue? The bisection looks a bit odd,
> but the commit in question does end up changing the key_control->thoff
> value for the failure case, so maybe that in turn ends up screwing up
> a later skb_pull.
>=20
> I'm not seeing anything that might fix this in the last networking
> pull, but I may have missed something.

I think that's the bug Eric has fixed today. See thread

	[PATCH net] flow_dissect: call init_default_flow_dissectors() earlier

David has queued up the fix and will send it your way shortly.

Andre
--=20
Max Planck Institute for Developmental Biology
Spemannstra=C3=9Fe 35, 72076 T=C3=BCbingen, Germany. Phone: (+49) 7071 601 =
829
http://people.tuebingen.mpg.de/maan/

--tT3UgwmDxwvOMqfu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg0xwsACgkQWto1QDEAkw8BzwCgohDRVJ7t2eCGk1had2OJdxlK
Ut8AnikEwAXIgaYNKkW/cdlasqJIxKmC
=4xs4
-----END PGP SIGNATURE-----

--tT3UgwmDxwvOMqfu--
