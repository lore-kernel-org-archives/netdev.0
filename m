From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 20:15:03 +0200
Message-ID: <1311963303.2873.9.camel@edumazet-laptop>
References: <20110729153207.17af3085@notabene.brown>
	 <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop>
	 <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
	 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110729165345.GM23194-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 juillet 2011 =C3=A0 12:53 -0400, J. Bruce Fields a =C3=A9=
crit :

> (Annoying fact: some initscripts stop nfsd using a rough equivalent o=
f
> "killall nfsd".  So the name of the threads is arguably ABI.  I think
> those initscripts are nuts and deserve what they get, but that may be
> because I'm forgetting the reason they do that.)
>=20

Yes, it seems we cant change then...

I tried on a RHEL4 distro and "service nfs stop" could not stop my nfsd
threads if I changed their names as described.

Next, I am going to try nfsd/... =20

By the way, any idea why after "service nfs stop" I cannot unload sunrp=
c
module ?

# lsmod
Module                  Size  Used by
nfsd                  285597  3=20
lockd                  76103  1 nfsd
auth_rpcgss            45002  1 nfsd
sunrpc                231915  6 nfsd,lockd,auth_rpcgss
exportfs                3813  1 nfsd


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
