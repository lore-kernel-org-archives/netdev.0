From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 06:08:34 +0200
Message-ID: <1311998914.2873.27.camel@edumazet-laptop>
References: <1311921035.7845.10.camel@edumazet-laptop>
	 <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
	 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
	 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
	 <20110730093025.716f3f50@notabene.brown>
	 <20110729234857.GA30941@fieldses.org>
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
In-Reply-To: <20110729234857.GA30941-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 juillet 2011 =C3=A0 19:48 -0400, J. Bruce Fields a =C3=A9=
crit :
> On Sat, Jul 30, 2011 at 09:30:25AM +1000, NeilBrown wrote:
> >=20
> > rpc.nfsd 0
> >=20
> > will stop all nfsd threads.  Follow with
> >=20
> >   exportfs -f
> >=20
> > and you should be done.  I'm not 100% sure about the nfsv4 thread t=
hough -
> > would need to check.
>=20
> Should be fine.
>=20

What are the needed steps to be able to unload nfsd module ?

So far, I am unable to perform this without using -f option.





--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
