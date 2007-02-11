From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Sun, 11 Feb 2007 14:21:45 +0100
Message-ID: <1171200105.5032.6.camel@johannes.berg>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
	 <200702091811.40683.mb@bu3sch.de> <45CCF432.2070002@gentoo.org>
	 <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net>
	 <45CCC5DF.8010001@gentoo.org> <45CCCAE1.9080901@lwfinger.net>
	 <20070209213239.GA11650@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HabjsH22xbiwaB15Uhea"
Cc: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070209213239.GA11650-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-HabjsH22xbiwaB15Uhea
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-02-09 at 21:32 +0000, Matthew Garrett wrote:
> On Fri, Feb 09, 2007 at 01:26:25PM -0600, Larry Finger wrote:
>=20
> > My plan is to continue to maintain bcm43xx-SoftMAC for at least the BPH=
Y and 4306 revisions even
> > after d80211 becomes the in-kernel driver. Of course, I hope that we wi=
ll have found the killer bugs
> > by that time, and that maintenance will only require following kernel A=
PI changes.
>=20
> Just to make sure I'm understanding this correctly - does the v4=20
> firmware drop compatibility for older cards, or is it just that Broadcom=20
> dropped support in the driver at the same time as the firmware changed,=20
> and the new firmware will still also drive the old cards?

No, the older cards have a completely different MAC processor and
Broadcom hasn't bothered to create v4 firmware for it since they dropped
support for it along with creating new drivers (probably one decision
influenced the other, creating a v2 firmware is likely more work than a
v3+)

johannes

--=-HabjsH22xbiwaB15Uhea
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFzxho/ETPhpq3jKURAmT8AJwLO+5yZpmzpOOKMPASRjn/zqWaRACeImnK
CtK9IgSSd/ArTSLgFq4v/fM=
=c6OX
-----END PGP SIGNATURE-----

--=-HabjsH22xbiwaB15Uhea--

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
