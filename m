From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flowcache: Fix kernel panic in flow_cache_flush_task
Date: Thu, 05 Feb 2015 14:39:06 -0800 (PST)
Message-ID: <20150205.143906.2233107149659287418.davem@davemloft.net>
References: <20150205153649.GA3278@miroslavurbanek.com>
	<1423154648.31870.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mu@miroslavurbanek.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	tc@excello.cz, jh@excello.cz, fan.du@windriver.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423154648.31870.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Feb 2015 08:44:08 -0800

> On Thu, 2015-02-05 at 16:36 +0100, Miroslav Urbanek wrote:
>> flow_cache_flush_task references a structure member flow_cache_gc_wo=
rk
>> where it should reference flow_cache_flush_task instead.
>>=20
>> Kernel panic occurs on kernels using IPsec during XFRM garbage
>> collection. The garbage collection interval can be shortened using t=
he
>> following sysctl settings:
>>=20
>> net.ipv4.xfrm4_gc_thresh=3D4
>> net.ipv6.xfrm6_gc_thresh=3D4
>>=20
>> With the default settings, our productions servers crash approximate=
ly
>> once a week. With the settings above, they crash immediately.
>>=20
>> Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
>> Reported-by: Tom=E1=A8 Charv=E1t <tc@excello.cz>
>> Tested-by: Jan Hejl <jh@excello.cz>
>> Signed-off-by: Miroslav Urbanek <mu@miroslavurbanek.com>
>> ---
>=20
> Nice catch !
>=20
> Ok, but you do not need to cc so many people/lists
>=20
> netdev is fine, and we usually CC patch author, just in case.
>=20
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
