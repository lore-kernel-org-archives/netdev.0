From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Mon, 05 May 2008 00:48:31 +0200
Message-ID: <1209941311.3981.13.camel@johannes.berg>
References: <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
	 <1209909990.3753.0.camel@johannes.berg>
	 <20080504.154540.214129591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wiiaCynr+lpV8e7XFNY+"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504.154540.214129591.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wiiaCynr+lpV8e7XFNY+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 15:45 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Sun, 04 May 2008 16:06:30 +0200
>=20
> > [  256.241496] KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc))
> > failed at net/packet/af_packet.c (225)
> >=20
> > any ideas about that?
>=20
> This is exactly what happens if you change skb->truesize
> when a socket is still attached to the skb.

Ok, that makes sense. Then it also makes sense I never got that warning
again, I had left one of my test patches in too long.

johannes

--=-wiiaCynr+lpV8e7XFNY+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB49PaVg1VMiehFYAQKJ3RAAoXTvAuBKbxvTD3REHfplf6JKTt1Mf2Mt
kQNKKA5S3pDEEp3Gl9gD20ALtjT3ascyk/cfbUK+9urThpDwZQ9dfsvK8ykuXIXA
1kgLxMA+awSav9rhm2xpkzCqqoRxfkMD0dpaS2GeJi/dp/P7eAoxWvi2LkS3ovNb
3PGa7HKHEcIsgyBCQBwh/ODOzLISW+m7mOBJeJSZK1aJ2Ys37sjD//T8UkKy4KAy
kct0kklYBbeM2yajRS6B6ImBM61myITPAblvJMJd8qOueqRUuPlIzkx4ezEmBm/5
qOlPdKd8uTBYpTCxghcxXz7xlaX1ePxuPiPJpWPPslX/2f/AXCwg55wi5l3mZFaj
e/98gCyJLhkO2dTpSNqD+tOGO5/HXHV7CCrMVBbLvLgHvS6HLjbKRhSkieWYSbNB
YasnM2EYl69YNU+FSOOxXIKRHFz8oZh6iLvTEwi3SaaKNfvY0Kn8FYzMGs4Ph0P4
hBpgHo6pHxXQdR8xNWTIToeNZcT/KCq0D0J/O8zdeNmcGPXPk8USGeOgXvCEN7mn
rLRA+4rww04NgayFeAdl6WKYbE5ClKgE8qXtj7fGL7G/LhKISMEXTlVfmePT5TQK
xsXQ+xUHLZ0fQw+s2pHDh2AnOSgl3wfzeMNOjhUWcg4psRm1/iMo3rF2dyi17ykr
TEi3xqBLlYA=
=9cNC
-----END PGP SIGNATURE-----

--=-wiiaCynr+lpV8e7XFNY+--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
