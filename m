From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read
 lock.
Date: Tue, 06 May 2008 13:40:47 -0700 (PDT)
Message-ID: <20080506.134047.86330538.davem@davemloft.net>
References: <48206F4C.5050105@openvz.org>
	<200805061840.37713.netdev@axxeo.de>
	<4820997E.1070305@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-BkyiQQGWkgE@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4820997E.1070305-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date: Tue, 06 May 2008 21:46:38 +0400

> I do not quite like doing so. Since this relies on fact that kfree bears
> NULL pointers. But if we ever switch from kmalloc to kmem_cache_alloc,
> this will result in an oops.

The whole reason we made kfree allow NULL points is so that
checks for it would be ommitted at kfree calls sides, whether
they be direct or indirect.

Adding the check for some theoretical-or-not future change is
rediculious.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
