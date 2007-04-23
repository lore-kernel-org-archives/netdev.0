From: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH] refactor wireless Kconfig
Date: Mon, 23 Apr 2007 21:35:19 +0200
Message-ID: <20070423213519.2692d0fd@localhost>
References: <20070423183334.GC5883@tuxdriver.com>
	<20070423183443.GD5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070423183443.GD5883-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 14:34:43 -0400
"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:

> -comment "Obsolete Wireless cards support (pre-802.11)"
> -	depends on NET_RADIO && (INET || ISA || PCMCIA)
> +	  This option does not affect the kernel build, it only
> +	  let's you choose drivers.
          ^^^^^

> +config WLAN_80211
> +	bool "Wireless LAN (IEEE 802.11)"
> +	depends on NETDEVICES
> +	---help---
> +	  Say Y if you have any 802.11 wireless LAN hardware.
> +
> +	  This option does not affect the kernel build, it only
> +	  let's you choose drivers.
          ^^^^^

--
Ciao
Stefano
