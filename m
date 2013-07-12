From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH 3/3] ath10k: ATH10K should depend on HAS_DMA
Date: Fri, 12 Jul 2013 07:39:39 +0300
Message-ID: <87txk04cj8.fsf@kamboji.qca.qualcomm.com>
References: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
	<1373490216-12437-3-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373490216-12437-3-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> (Geert
	Uytterhoeven's message of "Wed, 10 Jul 2013 23:03:36 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> writes:

> If NO_DMA=y:
>
> drivers/built-in.o: In function `ath10k_skb_unmap':
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `ath10k_skb_map':
> drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
> drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
> drivers/built-in.o: In function `ath10k_htt_rx_ring_free':
> drivers/net/wireless/ath/ath10k/htt_rx.c:113: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `ath10k_htt_rx_amsdu_pop':
> drivers/net/wireless/ath/ath10k/htt_rx.c:296: undefined reference to `dma_unmap_single'
> drivers/net/wireless/ath/ath10k/htt_rx.c:389: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `__ath10k_htt_rx_ring_fill_n':
> drivers/net/wireless/ath/ath10k/htt_rx.c:146: undefined reference to `dma_map_single'
> drivers/net/wireless/ath/ath10k/htt_rx.c:150: undefined reference to `dma_mapping_error'
> drivers/built-in.o: In function `ath10k_htt_rx_attach':
> drivers/net/wireless/ath/ath10k/htt_rx.c:474: undefined reference to `dma_alloc_coherent'
> drivers/net/wireless/ath/ath10k/htt_rx.c:509: undefined reference to `dma_free_coherent'
> drivers/net/wireless/ath/ath10k/htt_rx.c:514: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `ath10k_htt_rx_detach':
> drivers/net/wireless/ath/ath10k/htt_rx.c:220: undefined reference to `dma_unmap_single'
> drivers/net/wireless/ath/ath10k/htt_rx.c:228: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `ath10k_skb_map':
> drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
> drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
> drivers/built-in.o: In function `ath10k_skb_unmap':
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `ath10k_skb_map':
> drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
> drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
> drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
> drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
> drivers/built-in.o: In function `ath10k_skb_unmap':
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
> drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
>
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Thanks, I'll take this and send forward.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
