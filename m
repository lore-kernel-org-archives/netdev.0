From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v2] net: rfkill: gpio: Enable module auto-loading for
 ACPI based switches
Date: Tue, 16 Sep 2014 15:59:11 -0400
Message-ID: <20140916195911.GC3622@tuxdriver.com>
References: <1410551368-37316-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38424 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbaIPUAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:00:11 -0400
Content-Disposition: inline
In-Reply-To: <1410551368-37316-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm merging this to the wireless tree...

On Fri, Sep 12, 2014 at 09:49:28PM +0200, Marcel Holtmann wrote:
> For the ACPI based switches the MODULE_DEVICE_TABLE is missing to
> export the entries for module auto-loading.
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> ---
> net/rfkill/rfkill-gpio.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 02a86a27fd84..5fa54dd78e25 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -163,6 +163,7 @@ static const struct acpi_device_id rfkill_acpi_match[] = {
>  	{ "LNV4752", RFKILL_TYPE_GPS },
>  	{ },
> };
> +MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
> #endif
> 
> static struct platform_driver rfkill_gpio_driver = {
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
