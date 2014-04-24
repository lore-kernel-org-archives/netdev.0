From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] 6lowpan: nuke net_ieee802154_lowpan() accessor when
 6lowpan is disabled
Date: Thu, 24 Apr 2014 12:36:26 -0400 (EDT)
Message-ID: <20140424.123626.601551201909346659.davem@davemloft.net>
References: <1398193438-23805-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mcgrof-IBi9RG/b67k@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1398193438-23805-1-git-send-email-mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Date: Tue, 22 Apr 2014 12:03:58 -0700

> From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>
> 
> Johannes noted this is not needed, all of the fragment
> accessors don't need CONFIG_NET_NS. This goes test compiled with
> CONFIG_BT_6LOWPAN=y and a disabled CONFIG_NET_NS.
> 
> CC: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> Cc: David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Signed-off-by: Luis R. Rodriguez <mcgrof-IBi9RG/b67k@public.gmane.org>

Applied, thanks Luis.
