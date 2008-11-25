From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_close_fix.patch
 [patch 2/6 ]
Date: Tue, 25 Nov 2008 00:29:50 -0800 (PST)
Message-ID: <20081125.002950.40297572.davem@davemloft.net>
References: <492ABD5A.4000006@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492ABD5A.4000006-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Mon, 24 Nov 2008 15:42:34 +0100

> Moved serial_open_count in hso_serial_open to
> prevent crashes owing to the serial structure being made NULL
> when hso_serial_close is called even though hso_serial_open
> returned -ENODEV, Alan Cox pointed out this happens,
> also put in sanity check in hso_serial_close
> to check for a valid serial structure which should prevent
> the most reproducable crash in the driver when the hso device
> is disconnected while in use.
> Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
