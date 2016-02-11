From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] ath10k: fix erroneous return value
Date: Fri, 12 Feb 2016 10:24:09 +1100
Message-ID: <CAGRGNgXr-XS+sCBDCKMKT0x_uQBeiUqS9fNigkBt6x7LbNJkPQ@mail.gmail.com>
References: <1455123535-26751-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Anton Protopopov <a.s.protopopov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455123535-26751-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

On Thu, Feb 11, 2016 at 3:58 AM, Anton Protopopov
<a.s.protopopov@gmail.com> wrote:
> The ath10k_pci_hif_exchange_bmi_msg() function may return the positive
> value EIO instead of -EIO in case of error.
>
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

This looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

> ---
>  drivers/net/wireless/ath/ath10k/pci.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
> index ee925c6..526acde 100644
> --- a/drivers/net/wireless/ath/ath10k/pci.c
> +++ b/drivers/net/wireless/ath/ath10k/pci.c
> @@ -1756,7 +1756,7 @@ static int ath10k_pci_hif_exchange_bmi_msg(struct ath10k *ar,
>                                             DMA_FROM_DEVICE);
>                 ret = dma_mapping_error(ar->dev, resp_paddr);
>                 if (ret) {
> -                       ret = EIO;
> +                       ret = -EIO;
>                         goto err_req;
>                 }
>
> --
> 2.6.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
