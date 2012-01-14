From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
Date: Sat, 14 Jan 2012 18:18:53 +0100
Message-ID: <1326561533.5287.26.camel@edumazet-laptop>
References: <1326558605.19951.7.camel@lappy>
	 <1326561043.5287.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Matt Mackall <mpm@selenic.com>, kaber@trash.net,
	pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326561043.5287.24.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 14 janvier 2012 =C3=A0 18:10 +0100, Eric Dumazet a =C3=A9crit=
 :

> Apparently SLUB calls sysfs_slab_add() from kmem_cache_create() while
> still holding slub_lock.
>=20
> So if the task launched needs to "cat /proc/slabinfo" or anything
> needing slub_lock, its a deadlock.
>=20
>=20

Bug added in commit 2bce64858442149784f6c88
(slub: Allow removal of slab caches during boot)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
