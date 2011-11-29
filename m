From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 22:17:24 +0100
Message-ID: <1322601444.2596.21.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.WNT.2.00.1111291359290.1036@TSI>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 14:00 -0700, Marc Aurele La France a =C3=
=A9crit :
> On Tue, 29 Nov 2011, Eric Dumazet wrote:
>=20
> > Le mardi 29 novembre 2011 =C3=A0 12:47 -0800, Roland Dreier a =C3=A9=
crit :
> >> Thanks Eric, I'll send this to Linus shortly.
>=20
> > Oh well, I forgot one rcu_read_unlock(), I'll send a V2...
>=20
> This also doesn't address the other dst_get_neighbour() instances=20
> introduced by=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dco=
mmitdiff;h=3D69cce1d1404968f78b177a0314f5822d5afdbbfb
>=20

Oh well, a complete audit is needed, and I have no choice but doing it.

Thanks !


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
