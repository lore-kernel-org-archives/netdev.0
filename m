From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH -next] netdevice zd1201: Use after free
Date: Thu, 18 Dec 2008 19:37:03 -0800 (PST)
Message-ID: <20081218.193703.92433900.davem@davemloft.net>
References: <20081031182207.GD4310@tuxdriver.com>
	<1225478896-28987-1-git-send-email-linville@tuxdriver.com>
	<4949F36B.7080707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4949F36B.7080707-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Thu, 18 Dec 2008 14:53:31 +0800

> | commit 3d29b0c33d431ecc69ec778f8c236d382f59a85f
> | Author: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> | Date:   Fri Oct 31 14:13:12 2008 -0400
> | 
> |     netdevice zd1201: Convert directly reference of netdev->priv to netdev_priv()
 ...
> 
> This commit changed the allocation of netdev, but didn't change
> the free method of it.
> This causes "zd" be used after the memory, which is pointed by "zd", being
> freed by free_netdev().
> 
> Signed-off-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Patch applied to net-next-2.6, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
