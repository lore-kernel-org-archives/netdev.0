From: Peter Rosin <peda@lysator.liu.se>
Subject: Re: [PATCH] adm8211: fix checkpatch errors for indentation and new
 line around switch-case
Date: Tue, 05 May 2015 14:03:30 +0200
Message-ID: <5548B192.8020808@lysator.liu.se>
References: <20150505113731.GA2885@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150505113731.GA2885@bytefire-computer>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
> index f07a618..058fb4b 100644
> --- a/drivers/net/wireless/adm8211.c
> +++ b/drivers/net/wireless/adm8211.c
> @@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
>  		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
>  
>  		switch (cline) {
> -		case  0x8: reg |= (0x1 << 14);
> -			   break;
> -		case 0x16: reg |= (0x2 << 14);
> -			   break;
> -		case 0x32: reg |= (0x3 << 14);
> -			   break;
> -		  default: reg |= (0x0 << 14);
> -			   break;
> +		case  0x8:
> +			reg |= (0x1 << 14);
> +			break;
> +		case 0x16:
> +			reg |= (0x2 << 14);
> +			break;
> +		case 0x32:
> +			reg |= (0x3 << 14);
> +			break;
> +		default:
> +			reg |= (0x0 << 14);
> +			break;
>  		}
>  	}
>  

Those 0x16/0x32 hexadecimal case-selectors looking suspiciously like
decimal bits need a comment if they are in fact correct, which I doubt.

Cheers,
Peter
