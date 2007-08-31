From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/11] cxgb3 - Update internal memory management
Date: Fri, 31 Aug 2007 09:36:30 -0400
Message-ID: <46D8195E.20802@garzik.org>
References: <20070822034941.9387.79621.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58548 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965076AbXHaNgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:36:32 -0400
In-Reply-To: <20070822034941.9387.79621.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Set PM1 internal memory to round robin mode
> It balances access to this internal memory for multiport adapters.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/regs.h  |    2 ++
>  drivers/net/cxgb3/t3_hw.c |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
> index 2824278..5e1bc0d 100644
> --- a/drivers/net/cxgb3/regs.h
> +++ b/drivers/net/cxgb3/regs.h
> @@ -1326,6 +1326,7 @@
>  #define V_D0_WEIGHT(x) ((x) << S_D0_WEIGHT)
>  
>  #define A_PM1_RX_CFG 0x5c0
> +#define A_PM1_RX_MODE 0x5c4
>  
>  #define A_PM1_RX_INT_ENABLE 0x5d8
>  
> @@ -1394,6 +1395,7 @@
>  #define A_PM1_RX_INT_CAUSE 0x5dc
>  
>  #define A_PM1_TX_CFG 0x5e0
> +#define A_PM1_TX_MODE 0x5e4
>  
>  #define A_PM1_TX_INT_ENABLE 0x5f8

Future note:

would be nice to see the above as enums as well


