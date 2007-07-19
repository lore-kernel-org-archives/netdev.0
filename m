From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v2 1/2] mac80211: improved short preamble handling
Date: Thu, 19 Jul 2007 15:15:13 -0400
Message-ID: <20070719191513.GD6603@tuxdriver.com>
References: <20070715140739.C13187B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc-AlSwsSmVLrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rt2400-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070715140739.C13187B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 15, 2007 at 03:07:39PM +0100, Daniel Drake wrote:
> Similarly to CTS protection, whether short preambles are used for 802.11b
> transmissions should be a per-subif setting, not device global.
> 
> For STAs, this patch makes short preamble handling automatic based on the ERP
> IE. For APs, hostapd still uses the prism ioctls, but the write ioctl has been
> restricted to AP-only subifs.
> 
> ieee80211_txrx_data.short_preamble (an unused field) was removed.
> 
> Unfortunately, some API changes were required for the following functions:
>  - ieee80211_generic_frame_duration
>  - ieee80211_rts_duration
>  - ieee80211_ctstoself_duration
>  - ieee80211_rts_get
>  - ieee80211_ctstoself_get
> Affected drivers (bcm43xx, rt2x00 and rtl8187) were updated accordingly.
> 
> Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>

Jiri, Michael -- this applies to upstream w/ just some offsets if you
ignore the driver bits that aren't upstream.  I'll be happy to handle
the patch monkeying if you are happy w/ this patch.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
