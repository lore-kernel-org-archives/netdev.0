From: Ding Tianhong <dthxman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/21] wireless: slight optimization of addr compare
Date: Mon, 23 Dec 2013 22:14:07 +0800
Message-ID: <52B8452F.4070508@gmail.com>
References: <52B7C600.8030907@huawei.com> <52B83EE1.4040705@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52B83EE1.4040705-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013/12/23 21:47, Felix Fietkau =E5=86=99=E9=81=93:
> On 2013-12-23 06:11, Ding Tianhong wrote:
>> Use the recently added and possibly more efficient
>> ether_addr_equal_unaligned to instead of memcmp.
> It looks to me like all of these (including the ones in the other
> similar patches) are in places, where the address data is aligned to =
at
> least 16 bit. Because of this, using ether_addr_equal instead of
> ether_addr_equal_unaligned would be much better for platforms without
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
>=20
> - Felix

Yes, the most of the place should use ether_addr_equal. thanks.

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
