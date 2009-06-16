From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Wed, 17 Jun 2009 01:09:48 +0200
Message-ID: <1245193788.21287.66.camel@johannes.local>
References: <1244889678.13033.6.camel@johannes.local>
	 <1244896094.13033.8.camel@johannes.local>
	 <20090616111842.GG3521@psychotron.englab.brq.redhat.com>
	 <1245151771.9256.3.camel@johannes.local>
	 <20090616123808.GK3521@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UE8ydtDeKZ87RgRr96Gg"
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090616123808.GK3521-YzwxZg+R7evSU73v1vjTzyO4YDw3rz4rAInAS/Ez/D0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-UE8ydtDeKZ87RgRr96Gg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-16 at 14:38 +0200, Jiri Pirko wrote:

> >> Yes, I've already converted unicast lists to use list_head there. I'm =
sending
> >> the patch doing the same for multicast lists soon.
> >
> >Very nice! After that maybe I'll take a look again at moving things into
> >a common structure -- I ultimately want to use a multicast list without
> >a netdev to sync multiple netdevs onto a common multicast list that is
> >not part of a netdev.
>=20
> I see, hmm, I think I can do this change with my conversion... I was thin=
king
> about similar thing as you suggest before...

I don't think the patch for converting the multicast lists will hit .31,
I take it?

I'd like to get this patch into the .32 tree once it opens
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-net-core-mc-=
sync-list.patch

but I don't know how to handle that wrt. your patch, which will clearly
conflict with mein. Will you be sending that soon?

I guess we could stick this one into wireless-testing, and then take it
out again once your patch hits the tree and offers me similar API for
list_head based multicast lists?

johannes

--=-UE8ydtDeKZ87RgRr96Gg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOCY3AAoJEODzc/N7+QmadVgQAIii74dXzgsltM2khSGbpJq0
+HduX2BMg43HlyA09C7iZJJ+U5I25pfyx3+zjqdy2blj/I76eSdEJLQlSjjxN5pd
8rCTJJMOrVByk+wqs9vlZVKMc42wf0YYN1GupBZgEyI8ofYSnZBFtVzKn49CLlDc
AQRb7UvAL0tIeM6Xm8wU7WPAP55isdn/0ah9yoCtPhC+cFcvR+xINGdHd0g+worx
JAIykN/RNrVhnVV11FqqL0xw2rtsEFzBH/zYN/dEGD442wBvgYnjOJK63BBX97SD
5sHCxqhh5HdqXKvB+I/fZS/WZX0PLyc+Rm4AsV1tp92eYuz0tIDitXA173cuWo11
bDmmV7gcdKvXezHHbE7u2fy1ckJfOiHImbyeYEfEkaLujZ/k3yoVK8W58NrSVPfS
FeeAkic3mkXcuiKpE6czRzWhFcmnkv6gbqC4F0vhXOxv8wxSnyhICeeW6WPWSxPt
ImZ56vLlsPdYKNryWp+txlW9aknJfWLaor5c0G1cQxuqgTCb1pPwtQgwdRZCt1fY
IFnkGqXQR9bYrGah1PnJnwr1GdLILylRGaLHUB1aM2T/nwngPs8nKNrZ+73e32Se
zcwm9vWjaV4Nl9SABbpV1HkYBEwhe3TJpnrtEJKs4x5LNni4dqcg7szeAUxeq9Pk
4j+0/6bXwx01uqO/Q5nm
=B1Ly
-----END PGP SIGNATURE-----

--=-UE8ydtDeKZ87RgRr96Gg--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
