From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [patch] net/mlx4: && vs & typo
Date: Tue, 28 Feb 2017 18:53:35 +0200
Message-ID: <c20c76d1-13e9-7036-245e-765e65f40722@mellanox.com>
References: <20170228120215.GA27947@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0073.outbound.protection.outlook.com ([104.47.2.73]:12928
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751558AbdB1S2x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 13:28:53 -0500
In-Reply-To: <20170228120215.GA27947@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 28/02/2017 2:02 PM, Dan Carpenter wrote:
> Bitwise & was obviously intended here.

Sure! Thanks for your patch.

>
> Fixes: 745d8ae4622c ("net/mlx4: Spoofcheck and zero MAC can't coexist")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Applies to net.git.
>
> diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
> index e965e5090d96..a858bcb6220b 100644
> --- a/include/linux/mlx4/driver.h
> +++ b/include/linux/mlx4/driver.h
> @@ -109,7 +109,7 @@ static inline void mlx4_u64_to_mac(u8 *addr, u64 mac)
>  	int i;
>
>  	for (i = ETH_ALEN; i > 0; i--) {
> -		addr[i - 1] = mac && 0xFF;
> +		addr[i - 1] = mac & 0xFF;
>  		mac >>= 8;
>  	}
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
