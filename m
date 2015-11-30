From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: usb: ch9200: use kmemdup instead of kmalloc +
 memcpy
Date: Sun, 29 Nov 2015 22:40:31 -0500 (EST)
Message-ID: <20151129.224031.1377764944004812313.davem@davemloft.net>
References: <1448446041-15663-1-git-send-email-anuplimbu14@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org, tklauser-93Khv+1bN0NBDgjK7y7TUQ@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: anuplimbu14-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448446041-15663-1-git-send-email-anuplimbu14-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Anup Limbu <anuplimbu14-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 25 Nov 2015 15:37:21 +0530

> replace kmalloc + memset with kmemdup
> 
> Signed-off-by: Anup Limbu <anuplimbu14-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I agree with Bjorn that this microturfing cleanup misses
the real higher level opportunity to use the usbnet_read_cmd()
and usbnet_write_cmd() helpers that already exist.

Over time I am getting more and more weary of laser focused
microscopic cleanups.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
