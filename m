From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/12] 6lowpan: introduce 6lowpan-nd
Date: Wed, 15 Jun 2016 20:03:59 +0900
Message-ID: <5761361F.5050406@miraclelinux.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160614115239.17788-1-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Alexander Aring wrote:
> Alexander Aring (12):
>   6lowpan: add private neighbour data
>   6lowpan: add 802.15.4 short addr slaac
>   6lowpan: remove ipv6 module request
>   ndisc: add __ndisc_opt_addr_space function
>   ndisc: add __ndisc_opt_addr_data function
>   ndisc: add __ndisc_fill_addr_option function
>   addrconf: put prefix address add in an own function
>   ipv6: introduce neighbour discovery ops
>   ipv6: export several functions
>   6lowpan: introduce 6lowpan-nd
>   6lowpan: add support for getting short address
>   6lowpan: add support for 802.15.4 short addr handling
> 
>  include/linux/netdevice.h     |   8 +-
>  include/net/6lowpan.h         |  16 +++
>  include/net/addrconf.h        |  10 ++
>  include/net/ndisc.h           | 248 +++++++++++++++++++++++++++++++++++++++---
>  net/6lowpan/6lowpan_i.h       |   4 +
>  net/6lowpan/Makefile          |   2 +-
>  net/6lowpan/core.c            |  50 ++++++++-
>  net/6lowpan/debugfs.c         |  39 +++++++
>  net/6lowpan/iphc.c            | 167 +++++++++++++++++++++++-----
>  net/6lowpan/ndisc.c           | 234 +++++++++++++++++++++++++++++++++++++++
>  net/ieee802154/6lowpan/core.c |  12 ++
>  net/ieee802154/6lowpan/tx.c   | 113 +++++++++----------
>  net/ipv6/addrconf.c           | 218 +++++++++++++++++++++----------------
>  net/ipv6/ndisc.c              | 123 +++++++++++++--------
>  net/ipv6/route.c              |   8 +-
>  15 files changed, 1004 insertions(+), 248 deletions(-)
>  create mode 100644 net/6lowpan/ndisc.c
> 

Looks good to me.

Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION
