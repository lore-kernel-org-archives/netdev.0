From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
Date: Tue, 08 Aug 2006 13:50:33 -0700
Message-ID: <44D8F919.7000006@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193355.1396.71047.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37292 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964986AbWHHUvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 16:51:42 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060808193355.1396.71047.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> Update the driver to make use of the NETIF_F_MEMALLOC feature.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> 
> ---
>  drivers/net/e1000/e1000_main.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -4020,8 +4020,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
>  		 */
>  		skb_reserve(skb, NET_IP_ALIGN);
>  
> -		skb->dev = netdev;
> -
>  		buffer_info->skb = skb;
>  		buffer_info->length = adapter->rx_buffer_len;
>  map_skb:
> @@ -4135,8 +4136,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
>  		 */
>  		skb_reserve(skb, NET_IP_ALIGN);
>  
> -		skb->dev = netdev;
> -
>  		buffer_info->skb = skb;
>  		buffer_info->length = adapter->rx_ps_bsize0;
>  		buffer_info->dma = pci_map_single(pdev, skb->data,
> -

can we really delete these??

Cheers,

Auke
