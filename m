From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sun, 28 Aug 2011 12:02:24 +0200
Message-ID: <1314525744.3036.10.camel@edumazet-laptop>
References: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
	 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
	 <20110730093025.716f3f50@notabene.brown>
	 <20110729234857.GA30941@fieldses.org>
	 <1311998914.2873.27.camel@edumazet-laptop>
	 <20110730160610.0b751ffd@notabene.brown>
	 <1312006990.2873.75.camel@edumazet-laptop>
	 <1312095534.2873.108.camel@edumazet-laptop>
	 <20110827000219.GF18699@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110827000219.GF18699-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 26 ao=C3=BBt 2011 =C3=A0 20:02 -0400, J. Bruce Fields a =C3=
=A9crit :
> On Sun, Jul 31, 2011 at 08:58:54AM +0200, Eric Dumazet wrote:
> > Le samedi 30 juillet 2011 =C3=A0 08:23 +0200, Eric Dumazet a =C3=A9=
crit :
> > > Le samedi 30 juillet 2011 =C3=A0 16:06 +1000, NeilBrown a =C3=A9c=
rit :
> > > > umount /proc/fs/nfsd
> > > >=20
> > > >=20
> > >=20
> > > Thans  a lot, this was the thing I missed !
> > >=20
> > >=20
> >=20
> > Hmm, after this, I left things as the were (nfsd module loaded, but=
 a 0
> > use count )
> >=20
> > I got a BUG while updatedb was running,
> > (I tried this on a debian machine/kernel)
> >=20
> > Same bug on :
> >=20
> > cat /proc/self/mounts=20
>=20
> Any luck figuring this out?
>=20
> I tried reproducing, by stopping everything to get nfsd refcount to
> zero:
>=20
> 	# lsmod | grep '^nfsd'
> 	nfsd                  300025  0=20
>=20
> then running 'cat /proc/self/mounts'.
>=20
> But I don't see any crash.
>=20
> This is only 3.1.0-rc1 plus some nfsd patches.
>=20
> --b.
>=20
> >=20
> > I'll take a look at this issue later, after my vacations, unless so=
meone
> > wants to take a look before me ;)

Unfortunately, latest linux tree doesnt even boot on my machine, so I
cannot reproduce the problem right now.

Last message displayed being "Switching to clocksource tsc"

Previous kernels were continuing with :

[    4.448417] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[    4.597727] Real Time Clock Driver v1.12b

Might be a problem with latest tty changes=20


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
