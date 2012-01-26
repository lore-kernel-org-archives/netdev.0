From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] netback: fix multi page ring size calculation.
Date: Thu, 26 Jan 2012 17:21:28 +0000
Message-ID: <1327598488.2585.7.camel@leeni.uk.xensource.com>
References: <1327598408-16214-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, "jeremy@goop.org" <jeremy@goop.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:57156 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab2AZRV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 12:21:29 -0500
In-Reply-To: <1327598408-16214-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the noise, I accidently sent the wrong patch.

Wei.

On Thu, 2012-01-26 at 17:20 +0000, Wei Liu wrote:
> ---
>  drivers/net/xen-netback/common.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 477e5ab..f3d95b3 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -60,9 +60,9 @@ struct xenvif_rx_meta {
>  #define MAX_BUFFER_OFFSET PAGE_SIZE
>  
>  #define NETBK_TX_RING_SIZE(_nr_pages)					\
> -	(__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE) * (_nr_pages))
> +	(__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages)))
>  #define NETBK_RX_RING_SIZE(_nr_pages)					\
> -	(__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE) * (_nr_pages))
> +	(__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages)))
>  
>  #define NETBK_MAX_RING_PAGE_ORDER 2
>  #define NETBK_MAX_RING_PAGES      (1U << NETBK_MAX_RING_PAGE_ORDER)
