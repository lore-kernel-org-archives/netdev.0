From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/5] net: add IEEE 802.15.4 socket family implementation
Date: Sun, 7 Jun 2009 08:25:43 +0200
Message-ID: <20090607062543.GA10730@uranus.ravnborg.org>
References: <cover.1244337432.git.slapin@ossfans.org> <47c250c4bb2069d4faa2d6c5217d1aae15a5bc34.1244337432.git.slapin@ossfans.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47c250c4bb2069d4faa2d6c5217d1aae15a5bc34.1244337432.git.slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> --- /dev/null
> +++ b/net/ieee802154/Makefile
> @@ -0,0 +1,4 @@
> +obj-$(CONFIG_IEEE802154) +=	af_802154.o
> +af_802154-objs		:= af_ieee802154.o raw.o dgram.o
> +
> +EXTRA_CFLAGS += -Wall -DDEBUG

Please change this to following style:
> +obj-$(CONFIG_IEEE802154) +=  af_802154.o
> +af_802154-y               := af_ieee802154.o raw.o dgram.o
> +
> +ccflags-y += -Wall -DDEBUG


	Sam
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
