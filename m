From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] e1000: add transmit timestamping support
Date: Sat, 28 Apr 2012 09:47:42 +0200
Message-ID: <1335599262.2900.50.camel@edumazet-glaptop>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
	 <1335553447-11964-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:65358 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab2D1Hrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:47:46 -0400
Received: by wgbdr13 with SMTP id dr13so1426031wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:47:45 -0700 (PDT)
In-Reply-To: <1335553447-11964-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 15:04 -0400, Willem de Bruijn wrote:
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 3d712f2..40438ea 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3261,6 +3261,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
>  	                     nr_frags, mss);
>  
>  	if (count) {
> +		skb_tx_timestamp(skb);
> +
>  		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
>  		/* Make sure there is space in the ring for the next send. */
>  		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);

Acked-by: Eric Dumazet <edumazet@google.com>
