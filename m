From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESUBMIT Patch 1/1] net: replace if()/BUG with BUG_ON
Date: Wed, 17 Jun 2015 08:28:14 +0200
Message-ID: <20150617062743.GA18998@redhat.com>
References: <1434515761-14796-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, willemb@google.com, al.drozdov@gmail.com,
	viro@zeniv.linux.org.uk, eyal.birger@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pankaj.m@samsung.com
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754010AbbFQG2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 02:28:19 -0400
Content-Disposition: inline
In-Reply-To: <1434515761-14796-1-git-send-email-maninder1.s@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 10:06:01AM +0530, Maninder Singh wrote:
> Use BUG_ON(condition) instead of if(condition)/BUG() .
> 
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>

Why not?

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
>  net/packet/af_packet.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b5989c6..c91d405 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -547,8 +547,7 @@ static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
>  {
>  	struct tpacket_kbdq_core *pkc;
>  
> -	if (tx_ring)
> -		BUG();
> +	BUG_ON(tx_ring);
>  
>  	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
>  			GET_PBDQC_FROM_RB(&po->rx_ring);
> -- 
> 1.7.1
