From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH] drivers/net/wireless/ath/ath5k: Change
	constant name
Date: Sat, 8 Aug 2009 12:20:01 -0400
Message-ID: <20090808162001.GA18271@hash.localnet>
References: <Pine.LNX.4.64.0908081521210.27715@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908081521210.27715-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 08, 2009 at 03:22:26PM +0200, Julia Lawall wrote:
> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> Elsewhere, the tqi_type field is compared to constants having a name
> beginning with AR5K_TX_QUEUE, rather than AR5K_TX_QUEUE_ID.  I have thus
> converted AR5K_TX_QUEUE_ID_CAB to AR5K_TX_QUEUE_CAB.  This does, however,
> change the value, so perhaps something else was wanted.
> 
> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Nice catch, thanks.  Shouldn't cause any problem with 2.6.31 since we
don't use the CAB queue yet, but it was definitely wrong.

Acked-by: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>


> diff --git a/drivers/net/wireless/ath/ath5k/qcu.c b/drivers/net/wireless/ath/ath5k/qcu.c
> index 6d5aaf0..eeebb9a 100644
> --- a/drivers/net/wireless/ath/ath5k/qcu.c
> +++ b/drivers/net/wireless/ath/ath5k/qcu.c
> @@ -362,7 +362,7 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
>  		}
>  
>  		if (tq->tqi_ready_time &&
> -		(tq->tqi_type != AR5K_TX_QUEUE_ID_CAB))
> +		(tq->tqi_type != AR5K_TX_QUEUE_CAB))
>  			ath5k_hw_reg_write(ah, AR5K_REG_SM(tq->tqi_ready_time,
>  				AR5K_QCU_RDYTIMECFG_INTVAL) |
>  				AR5K_QCU_RDYTIMECFG_ENABLE,
> 

-- 
Bob Copeland %% www.bobcopeland.com
