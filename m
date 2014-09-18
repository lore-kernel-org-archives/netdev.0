From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Thu, 18 Sep 2014 23:25:35 +0200
Message-ID: <1411075535.2034.5.camel@jlt4.sipsolutions.net>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
	 (sfid-20140911_224347_007930_B9E673A0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410467723-2550-1-git-send-email-vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20140911_224347_007930_B9E673A0)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-09-11 at 23:35 +0300, Vadim Kochan wrote:
> Added new netdev_ops callback for setting namespace in specific
> for this device way

> +++ b/include/linux/netdevice.h
> @@ -997,6 +997,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *	Callback to use for xmit over the accelerated station. This
>   *	is used in place of ndo_start_xmit on accelerated net
>   *	devices.
> + * int (*ndo_set_netns)(struct net_device *dev, struct net *net);
> + *      Callback to set net namespace in specific way for this device.

For the record, I don't consider it appropriate to set the net namespace
on one netdev and end up with multiple netdevs switching namespaces ...

As a result, I don't think this should done.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
