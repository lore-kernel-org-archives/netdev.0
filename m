From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath: changed kmalloc to kmemdup
Date: Mon, 18 Mar 2013 14:09:22 +0200
Message-ID: <878v5k9afh.fsf@kamboji.qca.qualcomm.com>
References: <1362919199-16292-1-git-send-email-epure.andrei@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linville@tuxdriver.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrei Epure <epure.andrei@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362919199-16292-1-git-send-email-epure.andrei@gmail.com>
	(Andrei Epure's message of "Sun, 10 Mar 2013 14:39:58 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrei Epure <epure.andrei@gmail.com> writes:

> Signed-off-by: Andrei Epure <epure.andrei@gmail.com>
> ---
>  drivers/net/wireless/ath/ath6kl/usb.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath6kl/usb.c b/drivers/net/wireless/ath/ath6kl/usb.c
> index 5fcd342..ffa1daa 100644
> --- a/drivers/net/wireless/ath/ath6kl/usb.c
> +++ b/drivers/net/wireless/ath/ath6kl/usb.c
> @@ -856,11 +856,9 @@ static int ath6kl_usb_submit_ctrl_out(struct ath6kl_usb *ar_usb,
>  	int ret;
>  
>  	if (size > 0) {
> -		buf = kmalloc(size, GFP_KERNEL);
> +		buf = kmemdup(data, size, GFP_KERNEL);
>  		if (buf == NULL)
>  			return -ENOMEM;
> -
> -		memcpy(buf, data, size);
>  	}

Thanks, applied to ath6kl.git.

-- 
Kalle Valo
