From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] netback: remove redundant assignment
Date: Tue, 6 Dec 2011 10:21:22 +0000
Message-ID: <1323166882.23681.46.camel@zakaz.uk.xensource.com>
References: <1323166100-7059-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:15722 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933052Ab1LFKVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 05:21:23 -0500
In-Reply-To: <1323166100-7059-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 10:08 +0000, Wei Liu wrote:
> New value for netbk->mmap_pages[pending_idx] is assigned in
> xen_netbk_alloc_page(), no need for a second assignment which
> exposes internal to the outside world.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 15e332d..3ecb5aa 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -940,8 +940,6 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
>  		if (!page)
>  			return NULL;
>  
> -		netbk->mmap_pages[pending_idx] = page;
> -
>  		gop->source.u.ref = txp->gref;
>  		gop->source.domid = vif->domid;
>  		gop->source.offset = txp->offset;
> @@ -1336,8 +1334,6 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>  			continue;
>  		}
>  
> -		netbk->mmap_pages[pending_idx] = page;
> -
>  		gop->source.u.ref = txreq.gref;
>  		gop->source.domid = vif->domid;
>  		gop->source.offset = txreq.offset;
