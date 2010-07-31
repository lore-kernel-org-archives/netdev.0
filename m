From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4] can: Add driver for esd CAN-USB/2 device
Date: Fri, 30 Jul 2010 21:57:42 -0700 (PDT)
Message-ID: <20100730.215742.71118882.davem@davemloft.net>
References: <201007271542.40997.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: matthias.fuchs-iOnpLzIbIdM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201007271542.40997.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Date: Tue, 27 Jul 2010 15:42:40 +0200

> +#ifdef CONFIG_SYSFS
> +	if (device_create_file(&intf->dev, &dev_attr_firmware))
> +		dev_err(&intf->dev,
> +			"Couldn't create device file for firmware\n");

This ifdef protection is unnecessary, device_create_file() et al.
are available always, so please remove these SYSFS ifdef tests.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
