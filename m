From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v6 0/4] Provide netdev naming-policy via sysfs
Date: Thu, 03 Apr 2014 14:03:24 -0400 (EDT)
Message-ID: <20140403.140324.1744832114380351572.davem@davemloft.net>
References: <1396432706-14470-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, teg-B22kvLQNl6c@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kay.sievers-tD+1rO4QERM@public.gmane.org
To: dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1396432706-14470-1-git-send-email-dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed,  2 Apr 2014 11:58:22 +0200

> This is v6 of the name_assign_type attribute for netdevs. Changes since v5 [1]:
>  - Acked-by: Kay Sievers
>  - rebased on net-next of today
> 
> Aimed for 3.15, but feel free to delay for 3.16 if you want it in -next for some
> more time.

I'm fine with the basic idea, but the implementation needs work and
this will be deferred to 3.16 in any event.

We really need to specify the name allocation type at alloc_netdev()
time, I know that's more work but that's the only way you can be sure
you caught all such cases.

I know you missed the ISDN layer, where the name can come from the
user via an ioctl().  I'm sure there were several more.

You can even do something like make alloc_netdev_enumerated()
be a shorthand for alloc_netdev(size, name, NET_NAME_ENUM, ...)

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
