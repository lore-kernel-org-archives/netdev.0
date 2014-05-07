From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable v2] net: cdc_mbim: __vlan_find_dev_deep need
 rcu_read_lock
Date: Wed, 07 May 2014 15:11:32 -0400 (EDT)
Message-ID: <20140507.151132.1974316124798488454.davem@davemloft.net>
References: <1399126367-27827-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399126367-27827-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sat,  3 May 2014 16:12:47 +0200

> Fixes this warning introduced by commit 5b8f15f78e6f
> ("net: cdc_mbim: handle IPv6 Neigbor Solicitations"):
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [ INFO: suspicious RCU usage. ]
> 3.15.0-rc3 #213 Tainted: G        W  O
> -------------------------------
> net/8021q/vlan_core.c:69 suspicious rcu_dereference_check() usage!
>=20
> other info that might help us debug this:
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 1
> no locks held by ksoftirqd/0/3.
 ...
> Fixes: 5b8f15f78e6f ("net: cdc_mbim: handle IPv6 Neigbor Solicitation=
s")
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> v2: get a ref to the netdev before releasing the lock.  Thanks to Eri=
c Dumazet
>=20
> Please add this to the stable v3.13 and v3.14 queues as well.  Thanks=
=2E

Applied, thanks a lot.

If someone feels slightly inspired it might be a good idea to rename
__vlan_find_dev_deep to __vlan_find_dev_deep_rcu.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
