From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 14:16:08 +0200
Message-ID: <1211199368.6252.19.camel@johannes.berg>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2)  <1211032475.6252.2.camel@johannes.berg>
	 <1211117795.686.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2UPt4qKi1GJIRJ0lv493"
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1211117795.686.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-2UPt4qKi1GJIRJ0lv493
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Instead of testing for wireless/, best thing would probably be to call
> SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
> wireless.  Some drivers may have to load firmware to figure out
> supported rates and encryption capabilities, but to be honest, NM does
> this to detect wireless devices and I haven't run into any issues in 4
> years using it.  If there are issues with drivers, then we need to fix
> the driver too.

I was about to propose calling SIOCGIWNAME since that is what
wireless-tools do and that linux/wireless.h indicates.

johannes

--=-2UPt4qKi1GJIRJ0lv493
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASDFvh6Vg1VMiehFYAQJKwxAAxJfeWZ6v5iO3NVKN7OZjWGU/2UeLhwUI
r603e7JOqfCIfBVBvmtHeOOmdSfon4KPAHg/MJPv7dVZEtuWN6iRGfeAHfYWHeee
MUj/jQl1uvj9Pya2MGsBB9MM5te85bvha2bCNEOsTPfcggIkDInzvQ89P1+8CdUy
o/1dk3b56Os4L4jWVyLpttm0QSZ5tKgXfqnKoDSf7KFMfBTktWu9icQaLddwkwSr
lGE+HJyx6a6SMycPO5H2oH3rtCv7hv5CLig7vL1mMruPLdelHd7jgUwAi2qSRJG3
MP8DwS5V8JkzEaSqvPGEqCcU9JcMr71nvWdG0+JhTdQIFzg3mjD7BOI0yD4oUdYQ
otCkmulKr0tEpKiOC13FidNd/J8MHfW+v5TWOJk1n7TVWDJPobCVy9i0EE3NLWlb
ItyZ8beEhq02ZK58F3S+GDIG0q7zxuwDvQGbSpExv35UA325hU8EyhZbSZ57rpro
IkiGYz28OFhvSgbjh4KyMj1MRskrh/s+UEq2OzamwhrLU8Qi2OHY/7HbLNxhthLo
hnmod+3SAuYIwn7y3nq2YO9nMJ84HkSM9I3LRf4mM8y8r56LwN9IbmHFgttLGvY7
LznGs0HPgIMReV2cDBXxqgGayNb47oPmkTNxYZFUGArk2/EDbHS9dJfepzrry+rA
XnZILSbWi1w=
=2st1
-----END PGP SIGNATURE-----

--=-2UPt4qKi1GJIRJ0lv493--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
