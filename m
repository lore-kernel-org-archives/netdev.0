From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 03/10] net: add IEEE 802.15.4 socket family
 implementation
Date: Thu, 04 Jun 2009 16:15:36 +0200
Message-ID: <1244124936.22576.73.camel@johannes.local>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	 <20090603173214.6d3997f7.akpm@linux-foundation.org>
	 <20090604111634.GA28064@doriath.ww600.siemens.net>
	 <20090604134455.GB2839@tuxdriver.com>
	 <bc64b4640906040710p5c7c941fi3341599bc3157b79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-LKnVfcSf/rHg6h/hVnUR"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bc64b4640906040710p5c7c941fi3341599bc3157b79-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-LKnVfcSf/rHg6h/hVnUR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-06-04 at 18:10 +0400, Dmitry Eremin-Solenikov wrote:

> We do try to fit the lines into 80 chars, but when that seems logical.
> I strongly dislike breaking comparations between lines.

There are a whole bunch of improvements possible at this particular
spot:

switch (X) {
case Y:
	if (A) {
		...
	}
	break;
...
}

can be written as

switch (X) {
case Y:
	if (!A)
		break;
	...
	break;
}


and=20

for (...) {
	if (A) {
		...
		break;
	}
}

can be written as

for (...) {
	if (!A)
		continue;
	...
	break;
}

etc.

Show some creativity!

johannes

--=-LKnVfcSf/rHg6h/hVnUR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKJ9cFAAoJEODzc/N7+Qmai7oP/jQyakMgyacJhwCi/6ITCkJi
Dou+6CfcmXfXiCAJUKfLz/VWwjjgfSPrHnfHGCOXdS1ZLDoN6TD+VOz8mJUkvMFh
f2UUIXcRFmuSinLuXbql1tUDnAQ/lWAt/Y8zjp/XdeFAd1f1CxUdqQjd5jgDlcqR
23td+LIoEGedejRvxJKl+j7z8qqgAy49Bo0xNnbJ7GpFJY9OoYLvdVVIDJ2dkkKo
zkYK3wg2CLZcke/VB9H4+2awSC61H52ad0iVkgRatXIQXl7DmBqx6PZRn0c2R705
PFaM8bC8m4TKKcOSzZSbv0+v8Uy5euTXgUSidJJHVdJPeLacOLX4DV6isgOGATZ+
0uNELJQ485xbRORO+uTxW07NcMrL2quGAVk+RucQKkuucyNbqNPDQLhEuucc9O0u
DVFGyRyXlnmaR6FZXpiuf//NywIzmYnCBHvuKQx9qGO3A5SFSJOL6CZOsASRR0nh
RKHXhP4lBcVOm5ESJGxvHppLS1S4G87nj/EeGJOfvuwYd0DeIEQ8Os5apImSvUka
QNmY9vyMbpB/it2FZva/8vLPyIIHgRXYgxti4HkdxpiYStwMWzQDG4yyRzee8bmD
YnY25NrBkCt49gS+eBt4qRqHcrU/5d5EOwScWHx+vD4myPCG5KnWjtqCOKtGxss5
0z8tf4nIiU4lv3v+aqoQ
=lsIx
-----END PGP SIGNATURE-----

--=-LKnVfcSf/rHg6h/hVnUR--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
