From: Eugene Krasnikov <k.eugene.e@gmail.com>
Subject: Re: [PATCH 4/7] net: wireless: wcn36xx: introduce WCN36XX_HAL_AVOID_FREQ_RANGE_IND
Date: Tue, 27 Jan 2015 20:01:00 +0000
Message-ID: <CAFSJ42ZydByi_u0auSGDx2A6_ObZGfjV7+kR_CzFYLORRHQ5wg@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051100.31866.37997.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:44797 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbA0UBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:01:01 -0500
In-Reply-To: <20150118051100.31866.37997.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you know when is this message used? sounds important.

2015-01-18 5:11 GMT+00:00 Andy Green <andy.green@linaro.org>:
> WCN3620 firmware introduces a new async indication, we need to
> add it as a known message type so we can accept it
>
> Signed-off-by: Andy Green <andy.green@linaro.org>
> ---
>  drivers/net/wireless/ath/wcn36xx/hal.h |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
> index a1f1127..b947de0 100644
> --- a/drivers/net/wireless/ath/wcn36xx/hal.h
> +++ b/drivers/net/wireless/ath/wcn36xx/hal.h
> @@ -345,6 +345,8 @@ enum wcn36xx_hal_host_msg_type {
>         WCN36XX_HAL_DHCP_START_IND = 189,
>         WCN36XX_HAL_DHCP_STOP_IND = 190,
>
> +       WCN36XX_HAL_AVOID_FREQ_RANGE_IND = 233,
> +
>         WCN36XX_HAL_MSG_MAX = WCN36XX_HAL_MSG_TYPE_MAX_ENUM_SIZE
>  };
>
>



-- 
Best regards,
Eugene
