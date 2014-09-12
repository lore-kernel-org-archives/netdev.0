From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: rfkill: gpio: Enable module auto-loading for ACPI based switches
Date: Fri, 12 Sep 2014 12:46:49 -0700
Message-ID: <277E9FBD-4284-44F4-896C-5A1D8E5E6814@holtmann.org>
References: <1410547842-50207-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:59658 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaILTqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 15:46:06 -0400
In-Reply-To: <1410547842-50207-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> The switches that are enumerated over ACPI require a MODULE_ALIAS to
> allow auto-loading of the module.
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> ---
> net/rfkill/rfkill-gpio.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
> 
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 02a86a27fd84..35e659392209 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -180,3 +180,12 @@ module_platform_driver(rfkill_gpio_driver);
> MODULE_DESCRIPTION("gpio rfkill");
> MODULE_AUTHOR("NVIDIA");
> MODULE_LICENSE("GPL");
> +
> +#ifdef CONFIG_ACPI
> +MODULE_ALIAS("acpi:BCM2E1A");
> +MODULE_ALIAS("acpi:BCM2E39");
> +MODULE_ALIAS("acpi:BCM2E3D");
> +MODULE_ALIAS("acpi:BCM2E64");
> +MODULE_ALIAS("acpi:BCM4752");
> +MODULE_ALIAS("acpi:LNV4752");
> +#endif

while this patch gets the job done, it is too complicated. We can just use MODULE_DEVICE_TABLE for it. I will send an updated version.

Regards

Marcel
