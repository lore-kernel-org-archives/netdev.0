From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Wed, 30 Nov 2011 06:26:08 +0100
Message-ID: <1322630768.2596.64.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
	 <1322601444.2596.21.camel@edumazet-laptop>
	 <1322602283.2596.25.camel@edumazet-laptop>
	 <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw@mail.gmail.com>
	 <alpine.WNT.2.00.1111291815410.1288@TSI>
	 <CAL1RGDWzVRc4jFtsKUC6FGrdAWn3_OThXpbChCETCR8UCrwDDA@mail.gmail.com>
	 <alpine.WNT.2.00.1111292212280.208@TSI>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.WNT.2.00.1111292212280.208@TSI>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 22:15 -0700, Marc Aurele La France a =C3=
=A9crit :
> On Tue, 29 Nov 2011, Roland Dreier wrote:
> > On Tue, Nov 29, 2011 at 5:17 PM, Marc Aurele La France <tsi@ualbert=
a.ca> wrote:
> >> On Tue, 29 Nov 2011, Roland Dreier wrote:
> >>> On Tue, Nov 29, 2011 at 1:31 PM, Eric Dumazet <eric.dumazet@gmail=
=2Ecom>
> >>> wrote:
> >>>> Here is the result of this audit, please double check and test i=
t, I
> >>>> only compiled this.
>=20
> >>> Thanks Eric... I'll queue this up and send it on once we get a go=
od
> >>> report from Marc.
>=20
> >> I can confirm that Eric's patch, retrofitted to 3.1.3, fixes the p=
roblem.
>=20
> > Oh... the problem was already in 3.1?
>=20
> Yes, but not in anything earlier.
>=20

Yes :

# git describe --contains f2c31e32b378a6653f
v3.1-rc1~24^2~11

It all depends if f2c31e32b378a6653f is backported to 3.0 someday, sinc=
e
it fixes bug added in commit f39925dbde778 (ipv4: Cache learned redirec=
t
information in inetpeer)

# git describe --contains  f39925dbde778 =20
v2.6.39-rc1~468^2~349



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
