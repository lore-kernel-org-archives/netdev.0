From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] cls_cgroup: get sk_classid only from full sockets
Date: Tue, 19 Apr 2016 20:09:41 -0400 (EDT)
Message-ID: <20160419.200941.2243700873263559566.davem@davemloft.net>
References: <146097943086.15300.8997345346172526153.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <146097943086.15300.8997345346172526153.stgit@buzz>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Date: Mon, 18 Apr 2016 14:37:10 +0300

> skb->sk could point to timewait or request socket which has no sk_classid.
> Detected as "BUG: KASAN: slab-out-of-bounds in cls_cgroup_classify".
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>

Applied, thank you.
