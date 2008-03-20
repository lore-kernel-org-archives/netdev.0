From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig symbol
Date: Thu, 20 Mar 2008 15:58:17 +0100
Message-ID: <1206025097.16475.139.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <87a5b0800803200739v6d222afck850f221eae1edd70@mail.gmail.com>
	 (sfid-20080320_143913_214765_488C899F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HXUuBJ2INb6D0oeDiMrA"
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Will Newton <will.newton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87a5b0800803200739v6d222afck850f221eae1edd70-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20080320_143913_214765_488C899F)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-HXUuBJ2INb6D0oeDiMrA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-03-20 at 14:39 +0000, Will Newton wrote:
> On Thu, Mar 20, 2008 at 2:34 PM, Johannes Berg
> <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>=20
> >  +For some ethernet hardware that cannot DMA to unaligned addresses lik=
e
> >  +4*n+2 or non-ethernet hardware, this can be a problem, and it is then
> >  +required to copy the incoming frame into an aligned buffer. Because t=
his is
> >  +unnecessary on architectures that can do unaligned accesses, the code=
 can be
> >  +made depend on CONFIG_ARCH_CAN_UNALIGNED_ACCESS like so:
> >  +
> >  +#ifdef CONFIG_ARCH_CAN_UNALIGNED_ACCESS
> >  +       skb =3D copy skb
> >  +#else
> >  +       skb =3D original skb
> >  +#endif
>=20
> Is this logic reversed?

Euh, indeed, thanks. Will repost after having more comments.

johannes

--=-HXUuBJ2INb6D0oeDiMrA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+J7iKVg1VMiehFYAQJybRAAqGr095wjFY1emELqFL2BspwuyWkX9CKW
Hs3p/z3GdakkP0WvH8x80ZIZZSJg09ijazjOHdiqcOXGsSSIMDlK4S2dHOiswhpM
qa9+MwBxy1wxql9YXHfMUpyesdNzQyNVZ39/PrNyMGnn6oAUNSy/lWLVmhjhTzqE
v9GdpOrKGJuDtGaI6NoEqpMf6/jcDWA0D8CCZDUjtuBgE0HsAnQRRL4uwuT+pMrG
Sc3CIE8gR1M+skJrxE7NOPMoeoBLc7byA4SKVzJ0a3fuIDwCSRAYsx5FIzllSUo3
RsgO87UtmUzCn+JNwEZXL9b0f1PpyFHuVgvZ144iEcxDcQrJ5pRJaghG3g+Gm6ZD
Fjl3F1kRenPqvjwEH8bxu3q1UA+osoXIIi8/HKCoLkVIRJmX3nPkMZgZwKHoBgR5
x0FwEH2hoZZf/pjsJGTGCmJPeg6km+S4Kkt0aCxWUCNntmuot6Dwf844O02M8JqA
knsigj3UDMqGvUUe4BjVTRvg4neLn4AVAxEna9T0AYhj1P0MoKLqTShO/CMeiEjo
PVNT3XVsIEPeMzhUC7bGZiZxgdDpPuUBhZ5Z5k98Lm2aL/WMoehcbF/kr1PZRmfO
6+m6oj3W70tSK+d2fGOQUzWH6JOH+L+bPv3M2umah4Ski6XOrffR0OLE7x1bmd6q
zjqj3AdY7s8=
=aVm4
-----END PGP SIGNATURE-----

--=-HXUuBJ2INb6D0oeDiMrA--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
