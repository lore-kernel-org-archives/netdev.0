From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 15:07:48 +0100
Message-ID: <1258466868.3682.13.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <200911171504.54170.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3hmV4QFY8KyHA4HerZrN"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200911171504.54170.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-3hmV4QFY8KyHA4HerZrN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-17 at 15:04 +0100, Michael Buesch wrote:
> On Tuesday 17 November 2009 14:46:25 Johannes Berg wrote:
> > --- wireless-testing.orig/net/bridge/br_if.c	2009-11-17 14:19:17.000000=
000 +0100
> > +++ wireless-testing/net/bridge/br_if.c	2009-11-17 14:20:03.000000000 +=
0100
> > @@ -390,6 +390,10 @@ int br_add_if(struct net_bridge *br, str
> >  	if (dev->br_port !=3D NULL)
> >  		return -EBUSY;
> > =20
> > +	/* No bridging devices that dislike that (e.g. wireless) */
> > +	if (dev->priv_flags & IFF_DONT_BRIDGE)
> > +		return -EINVAL;
>=20
> -EOPNOTSUPP?
> That would probably produce a better error message in userspace.

Good idea, will wait a bit for other comments and fix this when I send
as [PATCH].

johannes

--=-3hmV4QFY8KyHA4HerZrN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAq4xAAoJEODzc/N7+QmaIKAP/ApVx7BEWNYy2bOcZn3GcU3r
I1g5YkFjWJe5m8XIaAfx3cZ0yrnOx064iAC+16AhaZnYYzRbol+6EVqV8iGRbslW
lv6ZM7Io74/cJCiQI07NDyFZJLIpKk0RxeTZgrOPwtO7fVxRw9C/b3I6QPd9ypaV
Ei/RqUIiJEn6NIH+80Dv63Q5edy50Tk+KrNsfNGOOhTwg4ql4DSP3aAxDvnBODxO
OV2cvENI3M/ji3nbYCgixUjjG0uWG9GuJrY5u2EyZd1tJlyjRHyiT7JMFAVxYnhX
ReRBKRzjH3IP8Mh/f/Y20RC/TX9KzcMaGKkkSrUYFFLyFbButkB4hM+7ISVR/OEW
n+rqcMSrR4TqQcMia3w8okXHzdpBnTDw9u7jOS4cU7/U9rIooXQ32ODTPbBXvwd+
FhCavfiLuHV/z6UFyr4sGT60eSIeH2NrIVu3JTBfuxnbI+NV89szbOgIJG/RDQaB
ssjWL3G6NX8DLULIu9SduPtzy4nZI2uYsPpI5H5GLV1XZYu/8U6Ja5WSN1vvXF6D
vMNqtkTkbSkLzutRV7AtOCAVE+NUHcptzsJQDHgnM5Gtj3E37es/g9GyKWW3Pd/X
6YjpmoTuOQnhHQv/th6nuZheMzIU3DDcl+hfn5s8MCO6FFqjRhiP7NQr7DXacDxY
O00KLydlTXNwnKAfrpfn
=6DsT
-----END PGP SIGNATURE-----

--=-3hmV4QFY8KyHA4HerZrN--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
