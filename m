From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH] net: ieee802154: cc2520: Fix coding style issues
Date: Fri, 23 Jan 2015 15:09:32 +0530
Message-ID: <CAEUmHyYr6GRntbtSLdtcWbq13uzbhejLSkJtPRuhsseeSczyMA@mail.gmail.com>
References: <1422005180-13230-1-git-send-email-md.jamalmohiuddin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Aring <alex.aring@gmail.com>,
	linux-wpan - ML <linux-wpan@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:58609 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbbAWJje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 04:39:34 -0500
In-Reply-To: <1422005180-13230-1-git-send-email-md.jamalmohiuddin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mohammad Jamal,

These changes already there in the current bluetooth-next tree.

On Fri, Jan 23, 2015 at 2:56 PM, Mohammad Jamal
<md.jamalmohiuddin@gmail.com> wrote:
> This patch solves the coding style issues such as space after ,
> and removes the blank lines
>
> Signed-off-by: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
> ---
>  drivers/net/ieee802154/cc2520.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> index f9df9fa..dd129be 100644
> --- a/drivers/net/ieee802154/cc2520.c
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -513,7 +513,6 @@ err_tx:
>         return rc;
>  }
>
> -
>  static int cc2520_rx(struct cc2520_private *priv)
>  {
>         u8 len = 0, lqi = 0, bytes = 1;
> @@ -551,14 +550,14 @@ cc2520_ed(struct ieee802154_hw *hw, u8 *level)
>         u8 rssi;
>         int ret;
>
> -       ret = cc2520_read_register(priv , CC2520_RSSISTAT, &status);
> +       ret = cc2520_read_register(priv, CC2520_RSSISTAT, &status);
>         if (ret)
>                 return ret;
>
>         if (status != RSSI_VALID)
>                 return -EINVAL;
>
> -       ret = cc2520_read_register(priv , CC2520_RSSI, &rssi);
> +       ret = cc2520_read_register(priv, CC2520_RSSI, &rssi);
>         if (ret)
>                 return ret;
>
> @@ -947,7 +946,6 @@ static int cc2520_probe(struct spi_device *spi)
>         if (ret)
>                 goto err_hw_init;
>
> -
>         gpio_set_value(pdata->vreg, HIGH);
>         usleep_range(100, 150);
>
> --
> 1.7.9.5
>

-- 
Thanks and Regards,
Varka Bhadram.
