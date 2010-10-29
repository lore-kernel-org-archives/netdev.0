From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2/2] vmxnet: trivial annotation of protocol constant
Date: Fri, 29 Oct 2010 11:20:10 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1010291119270.8381@sbhatewara-dev1.eng.vmware.com>
References: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com> <1288235555-24675-2-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pv-drivers@vmware.com
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:51227 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755194Ab0J2SUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 14:20:10 -0400
In-Reply-To: <1288235555-24675-2-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>


On Wed, 27 Oct 2010, Harvey Harrison wrote:

> Noticed by sparse:
> drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
> drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
> drivers/net/vmxnet3/vmxnet3_drv.c:876:24: warning: restricted __be16 degrades to integer
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index e3658e1..21314e0 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -873,7 +873,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
>  	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
>  		skb_shinfo(skb)->nr_frags + 1;
>  
> -	ctx.ipv4 = (skb->protocol == __constant_ntohs(ETH_P_IP));
> +	ctx.ipv4 = (skb->protocol == cpu_to_be16(ETH_P_IP));
>  
>  	ctx.mss = skb_shinfo(skb)->gso_size;
>  	if (ctx.mss) {
> -- 
> 1.7.1
> 
> 
