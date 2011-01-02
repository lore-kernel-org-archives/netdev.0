From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 23:31:26 +0100
Message-ID: <1294007486.2535.259.camel@edumazet-laptop>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
	 <1294005329.2535.258.camel@edumazet-laptop>
	 <1294006616.5675.13.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294006616.5675.13.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 02 janvier 2011 =C3=A0 23:16 +0100, Stefani Seibold a =C3=A9=
crit :
> Am Sonntag, den 02.01.2011, 22:55 +0100 schrieb Eric Dumazet:
> > Le dimanche 02 janvier 2011 =C3=A0 16:31 +0100, stefani@seibold.net=
 a =C3=A9crit :
> > > From: Stefani Seibold <stefani@seibold.net>
> > >=20
> > > Changelog:
> > > 31.12.2010 first proposal
> > > 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
> > > 02.01.2011 kick away UDP-Lite support
> > >            change spin_lock_irq into spin_lock_bh
> > > 	   faster udpcp_release_sock
> > > 	   base is now linux-next
> >=20
> > Since you depend on zlib_adler32(), you should add a dependence in
> > Kconfig so that its available
> >=20
> > select ZLIB_INFLATE
> >=20
>=20
> No this is not necessary, since zlib_adler32() is defined as a static
> inline function in include/linux/zutil.h
>=20
>=20

Wow, this huge function is inlined, how shocking :)
