From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after final merge (net tree)
Date: Wed, 17 Feb 2010 08:13:28 +0100
Message-ID: <1266390808.2830.1.camel@edumazet-laptop>
References: <20100217174015.d1a8a478.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100217174015.d1a8a478.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 17 f=C3=A9vrier 2010 =C3=A0 17:40 +1100, Stephen Rothwell a=
 =C3=A9crit :
> Hi Dave,
>=20
> After merging, today's linux-next build (sparc64 defconfig) failed li=
ke
> this:
>=20
> In file included from include/linux/netfilter_ipv4/ip_tables.h:29,
>                  from arch/sparc/kernel/sys_sparc32.c:47:
> include/linux/netfilter/x_tables.h:525: error: expected declaration s=
pecifiers or '...' before 'nf_hookfn'
>=20
> Caused by commit 2b95efe7f6bb750256a702cc32d33b0cb2cd8223 ("netfilter=
:
> xtables: use xt_table for hook instantiation").  Missing direct inclu=
de
> of linux/netfilter.h?
>=20

Hi Stephen

David took care of this already.

http://marc.info/?l=3Dlinux-netdev&m=3D126636301220734&w=3D2
