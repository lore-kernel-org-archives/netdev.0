From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: phy: mdio-xgene: Add hardware dependency
Date: Thu, 8 Sep 2016 14:30:02 -0700
Message-ID: <CAKh23FkE4gFf4v-72BO_dpaGhTHShYBzZkRyz6EwSBYhDB31tw@mail.gmail.com>
References: <20160908162515.1a69cf67@endymion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:35439 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcIHVaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 17:30:04 -0400
Received: by mail-ua0-f181.google.com with SMTP id 95so28033738uaz.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 14:30:03 -0700 (PDT)
In-Reply-To: <20160908162515.1a69cf67@endymion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 7:25 AM, Jean Delvare <jdelvare@suse.de> wrote:
> The mdio-xgene driver is only useful on X-Gene SoC.
>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Iyappan Subramanian <isubramanian@apm.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/phy/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
>
> --- linux-4.8-rc5.orig/drivers/net/phy/Kconfig  2016-09-04 23:31:46.000000000 +0200
> +++ linux-4.8-rc5/drivers/net/phy/Kconfig       2016-09-08 15:05:08.815824055 +0200
> @@ -303,6 +303,7 @@ config MDIO_HISI_FEMAC
>
>  config MDIO_XGENE
>         tristate "APM X-Gene SoC MDIO bus controller"
> +       depends on ARCH_XGENE || COMPILE_TEST
>         help
>           This module provides a driver for the MDIO busses found in the
>           APM X-Gene SoC's.
>

Thanks.

Acked-by:  Iyappan Subramanian <isubramanian@apm.com>

> --
> Jean Delvare
> SUSE L3 Support
