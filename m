From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flowcache: Fix kernel panic in flow_cache_flush_task
Date: Thu, 05 Feb 2015 08:44:08 -0800
Message-ID: <1423154648.31870.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150205153649.GA3278@miroslavurbanek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	=?UTF-8?Q?Tom=C3=A1=C5=A1_Charv=C3=A1t?= <tc@excello.cz>,
	Jan Hejl <jh@excello.cz>, Fan Du <fan.du@windriver.com>
To: Miroslav Urbanek <mu@miroslavurbanek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150205153649.GA3278@miroslavurbanek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-02-05 at 16:36 +0100, Miroslav Urbanek wrote:
> flow_cache_flush_task references a structure member flow_cache_gc_wor=
k
> where it should reference flow_cache_flush_task instead.
>=20
> Kernel panic occurs on kernels using IPsec during XFRM garbage
> collection. The garbage collection interval can be shortened using th=
e
> following sysctl settings:
>=20
> net.ipv4.xfrm4_gc_thresh=3D4
> net.ipv6.xfrm6_gc_thresh=3D4
>=20
> With the default settings, our productions servers crash approximatel=
y
> once a week. With the settings above, they crash immediately.
>=20
> Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
> Reported-by: Tom=C3=A1=C5=A1 Charv=C3=A1t <tc@excello.cz>
> Tested-by: Jan Hejl <jh@excello.cz>
> Signed-off-by: Miroslav Urbanek <mu@miroslavurbanek.com>
> ---

Nice catch !

Ok, but you do not need to cc so many people/lists

netdev is fine, and we usually CC patch author, just in case.

Acked-by: Eric Dumazet <edumazet@google.com>
