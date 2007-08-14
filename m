From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/13] cxgb3 - Update rx coalescing length
Date: Tue, 14 Aug 2007 01:41:42 -0400
Message-ID: <46C14096.3020905@garzik.org>
References: <20070811062939.8040.31490.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46711 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941308AbXHNFlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:41:44 -0400
In-Reply-To: <20070811062939.8040.31490.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Set max Rx coalescing length to 12288
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/common.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
> index c46c249..55922ed 100644
> --- a/drivers/net/cxgb3/common.h
> +++ b/drivers/net/cxgb3/common.h
> @@ -104,7 +104,7 @@ enum {
>  	PROTO_SRAM_LINES = 128, /* size of TP sram */
>  };
>  
> -#define MAX_RX_COALESCING_LEN 16224U
> +#define MAX_RX_COALESCING_LEN 12288U

neither the patch nor description explains -why-


