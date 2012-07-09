From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 09 Jul 2012 16:15:29 +0800
Message-ID: <4FFA9321.4030407@cn.fujitsu.com>
References: <1341819910.3265.2106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341819910.3265.2106.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8809=E6=97=A5 15:45, Eric Dumazet =E5=86=
=99=E9=81=93:
> From: Eric Dumazet <edumazet@google.com>
>=20
> dev->priomap is allocated by extend_netdev_table() called from
> update_netdev_tables().
> And this is only called if write_priomap() is called.
>=20
> But if write_priomap() is not called, it seems we can have out of bou=
nds
> accesses in cgrp_destroy(), read_priomap() & skb_update_prio()
>=20
> With help from Gao Feng
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> ---
> net/core/dev.c            |    8 ++++++--
> net/core/netprio_cgroup.c |    4 ++--
> 2 files changed, 8 insertions(+), 4 deletions(-)

Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
