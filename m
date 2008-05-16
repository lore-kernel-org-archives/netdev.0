From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Fri, 16 May 2008 12:38:58 +0200
Message-ID: <1210934338.4000.24.camel@johannes.berg>
References: <20080508032208.GA401@gondor.apana.org.au>
	 <200805161201.48835.rusty@rustcorp.com.au>
	 <20080515.215823.28841530.davem@davemloft.net>
	 <200805162032.48469.rusty@rustcorp.com.au>
	 (sfid-20080516_123407_138874_003A5D7F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VZds1be4maOlaCNsOgfd"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200805162032.48469.rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org> (sfid-20080516_123407_138874_003A5D7F)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VZds1be4maOlaCNsOgfd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I put a patch in to do exactly that at Herbert's prompting, for 2.6.26, b=
ut=20
> it's buggy in (at least) two ways.  I have a fix for this, which adds a n=
ew=20
> tasklet to xmit the packet.  There's still some subtle race, however, sin=
ce=20
> I'm still seeing a stuck packet.  I'll have to revert to TX_BUSY for 2.6.=
26=20
> if I can't find it (unlikely).

Incidentally, mac80211 has a tasklet for this as well, and I'm pretty
sure it's also buggy in the corner cases (rather than inefficient or
something)

johannes

--=-VZds1be4maOlaCNsOgfd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASC1kQaVg1VMiehFYAQKEvg/+IsfkpctQ26S9HoVt4QDI2aeZAHLcQird
PcUmSemFb2uiu4LWey+7ia7D841XYLyrAfV/JmRP+HP68TF2x5SbeXV2AxaNMb96
oitVUqh+SMctAbJ28gF/eekeJ4/7WQ2Iv3I7ywWv+1ZfxREellRjZpe2ix3AVoCc
Ak9bkASOkY7PER7S+gE3+MQlbUQLuCJvQTdc3hAHsGHAv33xKHHnLf4xykKOqq3h
MkFErN4t+XIlV9PCeJEiXcOFFXbfHidDImGA5RUiqBdMAMCD6EVe3ISZoJeRIGSW
wMFEsWBceSpy+ykHkEJn9uo9oDWDTL2CGVMWav1Y20NJSCQyaRh+GNV1kjQTLueF
+6RRIknEvfN3MabU2Uv7pfIMeo1pLPBIDDDeVKfVuC/l6EH+1ywODHrx9ziePyJZ
ljuut5roCMjQAPBU+ZwOe9sEfi78ahFeiHTnKcG1KpFUZ/vUUD3JWvCGbiYgZmI6
qjcN42x2wn9L+xAJuZEvei0HgS9/P/owkq/ybVlPy+IofScV36sXeut8EyN+oLxG
U9hdN4aYltsDq9Kt65D7i6cDmW4R2rb5aTuaf4HWMicfC74OcclvD3DhIPv/xl60
bMdhpZTqj79nh4iArI4GE1YrinBVL05O9UTe5OuxZlztFmjk/gj4zKJze+sRYP+o
b1i39aOtDm4=
=JmTb
-----END PGP SIGNATURE-----

--=-VZds1be4maOlaCNsOgfd--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
