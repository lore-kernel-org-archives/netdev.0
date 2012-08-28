From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192c: remove pointless conditional before
 kfree_skb()
Date: Tue, 28 Aug 2012 09:44:06 -0500
Message-ID: <503CD936.1030004@lwfinger.net>
References: <CAPgLHd_q0T=RD+qgEzFpnhez4Hdu-jDuFf0E+MgwiWLSeaMYaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54210 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab2H1OoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 10:44:12 -0400
In-Reply-To: <CAPgLHd_q0T=RD+qgEzFpnhez4Hdu-jDuFf0E+MgwiWLSeaMYaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2012 08:12 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Remove pointless conditional before kfree_skb().
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

Acked-by: Larry Finger <Larry.Finger.net>

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
> index 44febfd..b627151 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
> @@ -577,8 +577,7 @@ static bool _rtl92c_cmd_send_packet(struct ieee80211_hw *hw,
>   	ring = &rtlpci->tx_ring[BEACON_QUEUE];
>
>   	pskb = __skb_dequeue(&ring->queue);
> -	if (pskb)
> -		kfree_skb(pskb);
> +	kfree_skb(pskb);
>
>   	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
>
>
>
>
