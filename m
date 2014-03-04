From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] at86rf230: add help and 212 to Kconfig menu entry
Date: Tue, 04 Mar 2014 21:13:42 +0300
Message-ID: <531617D6.8040902@cogentembedded.com>
References: <1393928550-31949-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>,
	alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:46080 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbaCDRNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 12:13:43 -0500
Received: by mail-la0-f48.google.com with SMTP id gf5so5825861lab.35
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 09:13:41 -0800 (PST)
In-Reply-To: <1393928550-31949-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/04/2014 01:22 PM, Alexander Aring wrote:

> Since commit e035b8addc544c2b4de2f8b0326ba7939abd9541 we support at86rf212

    Please also specify that commit's summary line in parens.

> aswell.

    As well.

> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>   drivers/net/ieee802154/Kconfig | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
> index 08ae465..807ad1f 100644
> --- a/drivers/net/ieee802154/Kconfig
> +++ b/drivers/net/ieee802154/Kconfig
> @@ -32,8 +32,14 @@ config IEEE802154_FAKELB
>
>   config IEEE802154_AT86RF230
>           depends on IEEE802154_DRIVERS && MAC802154
> -        tristate "AT86RF230/231 transceiver driver"
> +        tristate "AT86RF230/231/212 transceiver driver"

    You need to indent with tab here.

>           depends on SPI
> +	---help---
> +	  Say Y here to enable the at86rf230/231/212 SPI 802.15.4 wireless
> +	  controller.
> +
> +	  This driver can also be built as a module. To do so, say M here.
> +	  the module will be called 'at86rf230'.

WBR, Sergei
