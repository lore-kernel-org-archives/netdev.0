From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 04/11] pcmcia: do not use io_req_t after call to
 pcmcia_request_io()
Date: Sun, 01 Aug 2010 11:04:43 -0700
Message-ID: <1280685883.12579.8.camel@localhost.localdomain>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
	 <1280667550-3040-4-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1280667550-3040-4-git-send-email-linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

> After pcmcia_request_io(), do not make use of the values stored in
> io_req_t, but instead use those found in struct pcmcia_device->resource[].
> 
> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org
> CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
> CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>

for the drivers/bluetooth/ pieces.

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
