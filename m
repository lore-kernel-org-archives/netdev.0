From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 11:34:44 +0200
Message-ID: <1209634484.4008.18.camel@johannes.berg>
References: <1209607368.7173.20.camel@johannes.berg>
	 <200805011058.40197.mb@bu3sch.de> <1209632886.4008.8.camel@johannes.berg>
	 <200805011132.24399.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-M6yXndIGPG5T6Q54qIRG"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200805011132.24399.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-M6yXndIGPG5T6Q54qIRG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-01 at 11:32 +0200, Michael Buesch wrote:
> On Thursday 01 May 2008 11:08:06 Johannes Berg wrote:
> >=20
> > > Hm, unrelated to this...
> > > But I am wondering what happens if the driver adds a device header to=
 the skb.
> > > Is that header then also passed up netif_rx()?
> > > This doesn't happen for b43, as we use the DMA fragmentation to trans=
mit the header,
> > > but it might happen for zd1211rw and others.
> >=20
> > Hmm. I thought we said that it was supposed to be removed again by the
> > hardware before TX status reporting. That's what most drivers seem to d=
o
> > anyway.
>=20
> Ok. I was not aware of that. Is that documented somewhere? I guess we can=
't WARN_ON()?

Not sure. We could try to analyse the packet header and see if it's
802.11, or put a length into skb->cb (after my rework to put things into
skb->cb we have a single byte free so we could check skb->len % 256)

johannes

--=-M6yXndIGPG5T6Q54qIRG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmOs6Vg1VMiehFYAQJl1w/+Ppx+IpBJFn1RHWsQPxeqRiEEFqAl85eY
WdELlhyZByrJyPpyK+rxP8AGr3QNDyHT4e7RFLKi94Uw479SEaJ2hFX0qKtiRJI5
AEdFB5NW1OZHBhaTnS+26bm5Bd3Wjkd3rmSwGEt6vKDuB4/o7k88xFcgLbPTc0j7
scvqTOajei/CIzTYuzASYHVtHCtrVOb2T60XnEqGpSFQY1bt1ewui1be7sftLt13
x1eDcOUfT05xs0AVn0T67KQ04IupAeoZAVRZGg5XkwE3uxwYJTTUeeB7jC29UYD2
dlBoHHQQVn23lONxDZPnES7om6jkfDjhNtxQhnBNp/WRcrhtuPMjioVDQJgm+cUk
UUglsLaUQJOWBwMC+DBFQn0tr99vo4YSwx+NnKBmnbXT6Wvj8lsL7zEnE7Z+Gsu0
Jbgsqn5n4GAY7XjLxhUN7ORXPXSXa6F60Pvq+d8qr6z8yYQjk+SV5Aepw4YX7qOe
HMBMFMpOpSeuG7mK52big3VqZCkLHV84DG8OB4ZPXpYgPNC5rfIM9ltTgmML82wY
7IEQd8V8wquginG1kv95mIj9POyrpb0Vmy2+VDkrC3C4wZelL2rKsmboKtaFL9r6
C6MjXbnLK8gSlmWkZweR0BRFBcSo5bMk6xScbz4jh0mrmV4OxSt0pXola90q0LRZ
QhCcJs/JijM=
=vdfg
-----END PGP SIGNATURE-----

--=-M6yXndIGPG5T6Q54qIRG--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
