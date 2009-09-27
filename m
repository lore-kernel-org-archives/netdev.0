From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] net: introduce NETDEV_PRE_INIT notifier
Date: Sun, 27 Sep 2009 13:11:34 -0700
Message-ID: <1254082294.2659.9.camel@localhost.localdomain>
References: <1254075999.6583.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254075999.6583.4.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

> For various purposes including a wireless extensions
> bugfix, we need to hook into the netdev creation at
> a point before netdev_register_kobject(). It seems
> more generic, however, to have it even earlier. This
> will also ease doing the dev type assignment that
> Marcel was working on generically.

you are beating me to it. I can only second that this is a good idea for
the dev type assignment. Once Dave acks this I can sent a rebased patch
for the dev type stuff for WiFi.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
