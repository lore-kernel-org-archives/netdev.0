From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-10-01
Date: Thu, 01 Oct 2009 12:43:44 -0700 (PDT)
Message-ID: <20091001.124344.88736363.davem@davemloft.net>
References: <20091001182450.GD2895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091001182450.GD2895-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 1 Oct 2009 14:24:51 -0400

> One is a brown paper bag fix for an uninitialized variable, another is a
> USB ID.  There is a beaconing fix for the mac80211_hwsim "fake" driver,
> and a bug fix for AP mode related to buffering frames for stations in
> power save mode.
> 
> The b43 fix looks a bit long, but it is more-or-less the same simple
> fix applied in multiple places.  It addresses a bug where "the last
> bytes of data sent/received to/from PIO FIFOs on SDIO-based cards get
> 'swizzled' when its length is not multiple of 4 bytes."
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.

I'll try to make sure the netif_rx_ni() et al. discussion keeps
making forward progress so that will get fixed too :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
