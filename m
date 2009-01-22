From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 3/9] bnx2x: annotate addr_hi/addr_lo as le32
Date: Thu, 22 Jan 2009 19:49:45 +0200
Message-ID: <1232646585.29087.87.camel@lb-tlvb-eliezer>
References: <1232517048.9701.21.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760090AbZAVRuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:50:51 -0500
In-Reply-To: <1232517048.9701.21.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> Remove a completely unused structure definition as well.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

[...]
>  
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 2f8d64c..021c31c 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -987,8 +987,8 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
>  	__free_pages(page, PAGES_PER_SGE_SHIFT);
>  
>  	sw_buf->page = NULL;
> -	sge->addr_hi = 0;
> -	sge->addr_lo = 0;
> +	sge->addr_hi = cpu_to_le32(0);
> +	sge->addr_lo = cpu_to_le32(0);
>  }

I prefer to keep zeros as zeros. I find it less readable with the
cpu_to_le macro. I also noticed that it does not add a sparse warning,
so on the combined image I will keep the zeros as zeros.
 
Other than that, the patch looks fine


