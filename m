From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 29 Dec 2014 23:25:07 -0500 (EST)
Message-ID: <20141229.232507.2086816594770925202.davem@davemloft.net>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>
	<CAHA+R7M-Nm_R-AaKQ0nX4L3O=BN5_m1v-8sWJSaE_UmGyo8zwA@mail.gmail.com>
	<54A21596.7000706@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54A21596.7000706-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wengang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Tue, 30 Dec 2014 11:01:42 +0800

> There are more than one way we do things. For this case, considering
> needs, complexity and stability I think moving ipoib_header_ops is the
> right way to go.

I completely disagree, it's a gross hack at best.

It's papering over the real problem.

When we have references to released objects in other areas of the
networking stack, we don't move those objects into the static kernel
image as a fix.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
