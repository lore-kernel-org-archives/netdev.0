From: "Divy Le Ray" <divy@chelsio.com>
Subject: Re: [RFC] [PATCH] cxgb3: Set the rxq
Date: Fri, 23 Oct 2009 17:29:44 -0700
Message-ID: <op.u193nu1zduofyu@speedy5>
References: <20091023111321.4726.29354.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Krishna Kumar" <krkumar2@in.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6636 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbZJXA3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 20:29:45 -0400
In-Reply-To: <20091023111321.4726.29354.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Oct 2009 04:13:21 -0700, Krishna Kumar <krkumar2@in.ibm.com>  
wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
>
> Set the rxq# for LRO when processing the last fragment of a
> frame. This helps in fast txq selection for routing workloads.
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>
>  drivers/net/cxgb3/sge.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff -ruNp org/drivers/net/cxgb3/sge.c new/drivers/net/cxgb3/sge.c
> --- org/drivers/net/cxgb3/sge.c	2009-10-19 11:58:16.000000000 +0530
> +++ new/drivers/net/cxgb3/sge.c	2009-10-20 09:40:40.000000000 +0530
> @@ -2135,6 +2135,7 @@ static void lro_add_page(struct adapter
>  	if (!complete)
>  		return;
> +	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
>  	skb->ip_summed = CHECKSUM_UNNECESSARY;
>  	cpl = qs->lro_va;
>

