From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: fix GCC warning on 64bit platforms
Date: Mon, 16 Jul 2007 14:53:58 -0700 (PDT)
Message-ID: <20070716.145358.35015496.davem@davemloft.net>
References: <20070714.185935.18577806.davem@davemloft.net>
	<20070714.204116.23012949.davem@davemloft.net>
	<20070716184653.355253bf@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jbenc-AlSwsSmVLrQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070716184653.355253bf-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Date: Mon, 16 Jul 2007 18:46:53 +0200

> net/mac80211/ieee80211.c: In function ieee80211_register_hw:
> net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
> 
> Fix by casting from size_t to unsigned as size of ieee80211_tx_status_rtap_hdr
> structure will never be greater than that.
> 
> Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>

The macro "max_t" exists for these kinds of situations, please
use it. :-)
