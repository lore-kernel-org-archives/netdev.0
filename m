From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Sat, 17 May 2008 16:42:34 +0200
Message-ID: <1211035354.6252.4.camel@johannes.berg>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2) <1211032475.6252.2.camel@johannes.berg>
	 <31B1A5D6-8E8B-4148-860F-326FEEE5A3EE@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-T6B3pK3mESP+Tct2gqvD"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <31B1A5D6-8E8B-4148-860F-326FEEE5A3EE-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-T6B3pK3mESP+Tct2gqvD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-05-17 at 16:36 +0200, Marcel Holtmann wrote:
> Hi Johannes,
>=20
> >>> The /sys/class/net/*/wireless/ direcory is, as far as I know, not
> >>> used by anyone. Additionally, the same data is available via wext
> >>> ioctls. Hence the sysfs files are pretty much useless. This patch
> >>> makes them optional and schedules them for removal.
> >>
> >> it is used by HAL to classify WiFi network cards as net.80211 instead
> >> of net.80203 and so we do have an actual user. However HAL only tests
> >> for the existence of the directory wireless/.
> >
> > Oh, ok, I didn't know that, thanks.
> >
> >> Please fix HAL first before submitting such a patch.
> >
> > Sure, I'll take a look at that.
>=20
> saw your patch. Looks good to me. However what do we do with the non-=20
> mac80211 drivers that are using WEXT directly. These should be =20
> detected as net.80211, too.

Yes, this was just a bigfix while I was looking at the code, I'll look
into that too :)

johannes

--=-T6B3pK3mESP+Tct2gqvD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASC7u2aVg1VMiehFYAQLflRAAw1vS+oHXO9cPa+Fd+XrN1+9ibKX/g52r
bFBI5SkcPO+0HnA8lAfM3PvOAtzjchmIWLhmGtkRPoLspmR2/C/SjrGkZTKjcfH9
mFiBHmS0eT07qydOK2lypMicTyB2X7ljEMHzoDvcvbSvcg2MeNj5kmjJauykkEh+
sdZnETq+FWM5+eJE4RdirkqvZUgJGReGClshyx/sNMqL1718QGT3D45Rp4g1M7IF
+zkhUJMZf7mhtQzv8afirsQm9UiAjglukV8o/PO+1imOeCBxcC2VhJjfMJ0vAhlo
acqxs3/7FTQC1Q+3Vk43RRpfMW89Cuxy4KiHOSwZu9PDxuTSbm3YBur+HeqnzzdB
uY4C7qPa40e06XnDeuaHiDbvWtyihCRX3FGgVBhpRO6fsdkf4eKVDYZSDs588lBz
3f5eaVpIWGN9VnWSxUbHUffNuiGUOrDLpQhtXD0PqT8hoojhDCChwRre9BZSgPCu
NPgMfmQRvRULAstlTXhGkm/g2LsBW62qW4VMDufr8Q5+0jZt2D5Ht51OTD4KA6LH
Z8U5igyOqhPhS25HKcaHkzNXFTDm7ZLeqb0juJSCgvEcxLXjsuNJjhPQVlZ2j5yg
gGDHsH0DzhFum+lVbq3iERKSr0PodnqS4zq9Sip9x5Ql7fDoDCShwblqm+Wwp6Zh
K1T4kZulkNw=
=p6JT
-----END PGP SIGNATURE-----

--=-T6B3pK3mESP+Tct2gqvD--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
