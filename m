From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] net: rfkill: gpio: Add OBDA8723 ACPI HID
Date: Sun, 9 Apr 2017 10:01:45 +0200
Message-ID: <D47F8D1B-8EE0-4754-A0F2-EC823A9BDA11@holtmann.org>
References: <20170408210520.2799-1-hdegoede@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408210520.2799-1-hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Hans,

> The OBDA8723 ACPI HID is used on quite a few Bay Trail based tablets
> for bluetooth rfkill functionality.
> 
> Tested-by: russianneuromancer-k+OT61UuxXo@public.gmane.org <russianneuromancer-k+OT61UuxXo@public.gmane.org>
> Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> net/rfkill/rfkill-gpio.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 76c01cb..50ca65e 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -163,6 +163,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
> static const struct acpi_device_id rfkill_acpi_match[] = {
> 	{ "BCM4752", RFKILL_TYPE_GPS },
> 	{ "LNV4752", RFKILL_TYPE_GPS },
> +	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
> 	{ },
> };

NAK. We are integrating these with hci_bcm.c or hci_intel.c drivers.

Regards

Marcel
