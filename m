From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: use correct index for invalidation in
 netbk_tx_check_mop()
Date: Fri, 18 Nov 2011 15:09:26 +0000
Message-ID: <1321628966.3664.363.camel@zakaz.uk.xensource.com>
References: <1321625599-3739-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Jan Beulich" <JBeulich@suse.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:5649 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756901Ab1KRPJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 10:09:28 -0500
In-Reply-To: <1321625599-3739-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-18 at 14:13 +0000, Ian Campbell wrote:
> From: Jan Beulich <JBeulich@suse.com>
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

I forgot to CC stable@ here. This applies to 2.6.39 onwards.

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 0cb594c..1ae270e 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1021,7 +1021,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
>  		pending_idx = *((u16 *)skb->data);
>  		xen_netbk_idx_release(netbk, pending_idx);
>  		for (j = start; j < i; j++) {
> -			pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
> +			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
>  			xen_netbk_idx_release(netbk, pending_idx);
>  		}
>  
