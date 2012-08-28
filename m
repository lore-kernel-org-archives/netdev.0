From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: rtl8192de: remove pointless conditional before
 kfree_skb()
Date: Tue, 28 Aug 2012 09:44:33 -0500
Message-ID: <503CD951.2090602@lwfinger.net>
References: <CAPgLHd86W5X=Tb_fXoz_Ood-w_s282QNePTXG9m_6ESdG-rG2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPgLHd86W5X=Tb_fXoz_Ood-w_s282QNePTXG9m_6ESdG-rG2A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/28/2012 08:11 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
>
> Remove pointless conditional before kfree_skb().
>
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192de/fw.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

Acked-by: Larry Finger <Larry.Finger.net>

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
> index 895ae6c..a3aede0 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
> @@ -570,8 +570,7 @@ static bool _rtl92d_cmd_send_packet(struct ieee80211_hw *hw,
>
>   	ring = &rtlpci->tx_ring[BEACON_QUEUE];
>   	pskb = __skb_dequeue(&ring->queue);
> -	if (pskb)
> -		kfree_skb(pskb);
> +	kfree_skb(pskb);
>   	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
>   	pdesc = &ring->desc[idx];
>   	/* discard output from call below */
>
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
