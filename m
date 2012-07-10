From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Tue, 10 Jul 2012 10:33:23 +0800
Message-ID: <4FFB9473.4040203@cn.fujitsu.com>
References: <1341819910.3265.2106.camel@edumazet-glaptop> <4FFA9321.4030407@cn.fujitsu.com> <20120709.145125.1903343847210013668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120709.145125.1903343847210013668.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8810=E6=97=A5 05:51, David Miller =E5=86=
=99=E9=81=93:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Mon, 09 Jul 2012 16:15:29 +0800
>=20
>> =E4=BA=8E 2012=E5=B9=B407=E6=9C=8809=E6=97=A5 15:45, Eric Dumazet =E5=
=86=99=E9=81=93:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> dev->priomap is allocated by extend_netdev_table() called from
>>> update_netdev_tables().
>>> And this is only called if write_priomap() is called.
>>>
>>> But if write_priomap() is not called, it seems we can have out of b=
ounds
>>> accesses in cgrp_destroy(), read_priomap() & skb_update_prio()
>>>
>>> With help from Gao Feng
>>>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Cc: Gao feng <gaofeng@cn.fujitsu.com>
>>> ---
>>> net/core/dev.c            |    8 ++++++--
>>> net/core/netprio_cgroup.c |    4 ++--
>>> 2 files changed, 8 insertions(+), 4 deletions(-)
>>
>> Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
>=20
> Applied.
>=20

Hi David

Please see my patch in this thread, I think it's a better way to fix th=
is bug.

Thanks.
