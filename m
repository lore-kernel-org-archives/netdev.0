From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4] e1000e: add transmit timestamping support
Date: Sat, 28 Apr 2012 09:47:53 +0200
Message-ID: <1335599273.2900.51.camel@edumazet-glaptop>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
	 <1335553447-11964-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43110 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab2D1Hr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:47:57 -0400
Received: by wejx9 with SMTP id x9so867009wej.19
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:47:56 -0700 (PDT)
In-Reply-To: <1335553447-11964-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 15:04 -0400, Willem de Bruijn wrote:
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 851f793..c5d9ad7 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -5150,6 +5150,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
>  	/* if count is 0 then mapping error has occurred */
>  	count = e1000_tx_map(tx_ring, skb, first, max_per_txd, nr_frags, mss);
>  	if (count) {
> +		skb_tx_timestamp(skb);
> +
>  		netdev_sent_queue(netdev, skb->len);
>  		e1000_tx_queue(tx_ring, tx_flags, count);
>  		/* Make sure there is space in the ring for the next send. */

Acked-by: Eric Dumazet <edumazet@google.com>
