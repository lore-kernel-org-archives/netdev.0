From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH 26/39]: netdev: netdev_priv() can now be sane again.
Date: Thu, 03 Jul 2008 13:23:32 +0200
Message-ID: <m3tzf7nrd7.fsf@maximus.localdomain>
References: <20080703.000446.125029084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080703.000446.125029084.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's message of "Thu\, 03 Jul 2008 00\:04\:46 -0700 \(PDT\)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> The private area of a netdev is now at a fixed offset once more.
>
> Unfortunately, some assumptions that netdev_priv() == netdev->priv
> crept back into the tree.  In particular this happened in the
> loopback driver.

Perhaps the netdev_priv() should be renamed to avoid confusion?
-- 
Krzysztof Halasa
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
