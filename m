From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH] net: qlcnic: Deletion of unnecessary memset
Date: Tue, 14 Jul 2015 08:48:10 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A472C2759@avmb2.qlogic.org>
References: <fad6a2ad1e78d8e2624903524548f8d806bf1ef0.1436816968.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fad6a2ad1e78d8e2624903524548f8d806bf1ef0.1436816968.git.christophe.jaillet@wanadoo.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Christophe JAILLET [mailto:christophe.jaillet@wanadoo.fr]
> Sent: Tuesday, July 14, 2015 1:22 AM
> To: Shahed Shaikh; Dept-GE Linux NIC Dev
> Cc: netdev; linux-kernel; kernel-janitors@vger.kernel.org; Christophe JAILLET
> Subject: [PATCH] net: qlcnic: Deletion of unnecessary memset
> 
> There is no need to memset memory allocated with vzalloc.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 2f6cc42..7dbab3c 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -2403,7 +2403,6 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter
> *adapter,
>  			qlcnic_free_tx_rings(adapter);
>  			return -ENOMEM;
>  		}
> -		memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
>  		tx_ring->cmd_buf_arr = cmd_buf_arr;
>  		spin_lock_init(&tx_ring->tx_clean_lock);
>  	}

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
