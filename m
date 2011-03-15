From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 11/17] net,rcu: convert call_rcu(sctp_local_addr_free)
 to kfree_rcu()
Date: Tue, 15 Mar 2011 14:03:59 -0700 (PDT)
Message-ID: <20110315.140359.39186121.davem@davemloft.net>
References: <4D7F3610.6000809@cn.fujitsu.com>
	<4D7F39CE.80403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-X9Un+BFzKDI@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, vladislav.yasevich-VXdhtT5mjnY@public.gmane.org,
	sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org,
	jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hagen-GvnIQ6b/HdU@public.gmane.org,
	randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, jkosina-AlSwsSmVLrQ@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D7F39CE.80403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Tue, 15 Mar 2011 18:05:02 +0800

> 
> 
> The rcu callback sctp_local_addr_free() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(sctp_local_addr_free).
> 
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
