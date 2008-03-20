From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC v2] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
	symbol
Date: Thu, 20 Mar 2008 22:21:46 +0100
Message-ID: <1206048106.16475.161.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
	 <1206038373.16475.150.camel@johannes.berg>
	 <20080320.141307.173590705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-U9d2Ty1Jta9zyVzH3MEN"
Cc: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080320.141307.173590705.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-U9d2Ty1Jta9zyVzH3MEN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I think you're semantically testing the wrong thing.
>=20
> It's not if unaligned accesses are supported, it's if they are
> efficient enough or not.
>=20
> For example, sparc64 fully handles unaligned accesses but taking the
> trap to fix it up is slow.  So sparc64 "can" handle unaligned
> accesses, but whether we want to set this symbol or not is another
> matter.

Yeah, good point. Should I rename it to HAVE_EFFICIENT_UNALIGNED_ACCESS
or similar? Or have it defined as some sort of number so you can make
actually make tradeoffs? Like Dave Woodhouse suggested at some point to
have get_unaligned() take an argument that indicates the probability...

johannes

--=-U9d2Ty1Jta9zyVzH3MEN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+LVaaVg1VMiehFYAQKGEQ//Y7tlbOZ+5VeIOIzFnf+/JvXG5K9e+xRc
SeHqW1/P4PBJErnpiu4x7Kskdxnth5prPpNnq6NKq0BwDGbwoKvNmJXDaHHFFsNI
tXRkf3eqIcPPDZqkp1COOudY0xXLYxFmt1UR8kPBgpR37MDGg3mZH5/45IotozAh
bAOAnFFKXrzk0yYLI7uHEWPV1whAjxKt4kAaTCFzG0r981uz7/EjitNHzdEg0IVe
nozFGn1+M7yw0WCaaxEZMzREDUjgmRUE8prRa6eGiqvnRMHhxRds+oauH0Rp0Vhq
ZTv2gKJbvF8ylTdHg8JEtRHB6eJhQapf182uyFXOmcgySze1E4rSZ0v4S1+jqGyE
AuXQ0phQziwPCja846vwW8hBHEEeFPVOcQEgDuMtzDZjytuILeHqwvfPvZbOEpp+
5G0FP83RAztR1zE8LDM5WkUWd7mmftgPQgsNMfNhWyHGD/BJ1rv3/Z05B/3kYL0A
e9QgNNh3MBvjJte7aFu+PjYpGvF9s9xguOOzmCRtAc6j6IQepQ+Ya87fMi5zRbQn
y+k5iJg/e806U3GY2KtFaO+EPjpFUteH9x47hv+T1gl4SCws3W15Vu5zxklBfSUP
+nBT2H+NUWAvPNgy9FvN8dmxLBnnmrX6YAZ1piV8N/OyUpQpnoVXCmxlljeGbE9H
mza/0C9i4YQ=
=zg7i
-----END PGP SIGNATURE-----

--=-U9d2Ty1Jta9zyVzH3MEN--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
