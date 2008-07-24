From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Thu, 24 Jul 2008 13:45:26 +0200
Message-ID: <1216899926.13587.51.camel@johannes.berg>
References: <4887550B.2070704@tvcablenet.be> <4887555A.30605@trash.net>
	 <48875B8C.2090800@trash.net> <20080723.142147.61941255.davem@davemloft.net>
	 <48884451.1090703@trash.net>
	 <1ba2fa240807240317g15f6ba84h91b513cce75975e9@mail.gmail.com>
	 <48885743.8030505@trash.net>
	 <1ba2fa240807240435g36daa80at254144afffc39c32@mail.gmail.com>
	 (sfid-20080724_133550_701095_354A4111)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FQSmg9yf1gLJUgJ+FKQ6"
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jussi.kivilinna-E01nCVcF24I@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240807240435g36daa80at254144afffc39c32-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20080724_133550_701095_354A4111)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-FQSmg9yf1gLJUgJ+FKQ6
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-07-24 at 14:35 +0300, Tomas Winkler wrote:

> >> Isn't this time to make 802.11 native?
> >
> >
> > You mean by making these things real skb members? I hope you're
> > not talking about the entire 48 bytes? :)
>=20
> I mean elevating 802.11 header to 802.3 level. Not doing 802.3 ->
> 802.11 translation where not needed.


We've discussed that over and over and over and over again, and it's not
going to fly since 802.11 throughout assumes that you have a two-address
data service to the upper layers.

Besides, making it 802.11 native doesn't help with the control
information at all.

johannes

--=-FQSmg9yf1gLJUgJ+FKQ6
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIiGtSAAoJEKVg1VMiehFYa/oP/3ADaXW8UwWpUa0U/+QH6Alc
zU2L+SbsVs5UcsN+yDHpkiIFlnljzm1iqqJCZR2QeonvrSWeLAJUrFBP3I0/SZjm
Vpx0czcVFjkUkpWt6ORmYXDAMaHk5w2pvsmCNno/7+l8jQCBr0TSTbiPjFIakUQ1
98JkAJMdrunZtze3HO8vWa0sRWvNlnJSe0SwIFAlgHBtf09OjQduvN3r05g767C+
GUZQEG1x2nLEql2yh6emwtZ4ukkMnQZ1gMbJsg7WOt/K498vYR4rvaxEh7QCVKqd
xNPm9Op62jQZJkY7sauHaMZXHjlpzSzy+MfOE3pgxtzaaWVvJbEFxVYfSNEPPkHF
FqDIYqO+9xJb+xxpyGB4wk5pgw/Wze1lD8e3gFv4ZT+JYX9QbYNiVpWfYhX18tlX
EU56karZokORizYj2LNc/iVeLeSohewuUIp1rqWLg74llAL1Zfp37cBKhw1Kgfms
6HnmyzBnemQVttbDHR4N7FwTt7qzBl56aeSDcqONymOWWrNu4F3Lk+P0SPwLQcni
ssPG7ralumgjnILy4QxL31dWbmrwMM8U2MATK0+IVvyh30yr1+578w5J1PBgrFkF
n4l5o6xzY2b56PFHdtM70yHcHuK5e4M3WA+SEsrQ/h4EmEFBL/Xf2l6AUunyNykW
TnMo90kdFEH2PE0wgqmY
=di0n
-----END PGP SIGNATURE-----

--=-FQSmg9yf1gLJUgJ+FKQ6--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
