From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 19:47:40 +0200
Message-ID: <1209923260.3655.2.camel@johannes.berg>
References: <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 <1209900355.6210.64.camel@johannes.berg>
	 <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
	 <1209909990.3753.0.camel@johannes.berg>
	 (sfid-20080504_160619_267031_C8D61782)  <1209917006.3753.2.camel@johannes.berg>
	 (sfid-20080504_180307_553231_1D0CF66C)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gpAn2hDt8EKy96+lvFWr"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209917006.3753.2.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_180307_553231_1D0CF66C)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-gpAn2hDt8EKy96+lvFWr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > [  256.241496] KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc))
> > failed at net/packet/af_packet.c (225)
>=20
> Except for that,=20

Oddly, I haven't been able to reproduce this, so I'll clean up the
patches now.


If I have a device that needs 100 bytes headroom (not unheard of),
there will of course still be packets that don't have enough headroom.
Should we skb_orphan them?

johannes

--=-gpAn2hDt8EKy96+lvFWr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB32u6Vg1VMiehFYAQIudw/+Na3Nw9rYuA7K4quD16gDGC+Z+yMKsqe2
R6mRF9NPpKBnO+RyOEr6IPdA84CcMX8GJAc7lmlPTFq9C8M1qPrTO2cISfnNQbdI
32T1CYsgbyDubO+N4/KApi1ehFkO7pr3NwRG6rHZvCZ7xFhR88gJI2BcCK0zslwk
ONlNlh1gs49e7J9eJXUU+8dj6so88+dj6gWHiHjlTRWXwZxQ3RhJUJlJtj3NX8Hq
71Adx+U5xX1goHLWcsHv8Zxch2jLlS7QI3gbBs+rD0Tw6vlYGrxH007VSzXxMgIE
gpzVB1vMMidHz75erE7vzjmwlNggVyzlVQItD5TuEqXsPych8c39MyVUde/VoPL1
3Z4fg31Eug1drNenr2l5RV9+87MvS3WJs9b2axiv2N19IH8auB9ZkJ+WafRoJgTM
OrgIWcZurc74H+YRaaGkCPd6eoiqjD3fgyGv9kaLB5slovyCty2no5n4mvCAYozl
4GfcQ83pikpIMRx6zjXhxYlDsRtyHiLsEPmkJohsgTHMwaTwsQbS9wZ418vC0UKd
O9Nj7OUlp1px2nw+ch94oRSagiTSzarH3TU/sxpeAOJFERSuGqlExoA7GDjvmfOo
fcYSaTwCRzqc7olvH1Emq3eXx3JAf1EbNhiidI4rdFrC6t16AyuU9ny7PGw+XOWp
Tsp+CguoP9Q=
=6eYc
-----END PGP SIGNATURE-----

--=-gpAn2hDt8EKy96+lvFWr--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
