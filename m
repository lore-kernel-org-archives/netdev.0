From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] netback: fix typo in comment
Date: Tue, 6 Dec 2011 13:40:54 +0000
Message-ID: <1323178854.23681.75.camel@zakaz.uk.xensource.com>
References: <1323173090-7867-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:54789 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933131Ab1LFNkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 08:40:55 -0500
In-Reply-To: <1323173090-7867-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 12:04 +0000, Wei Liu wrote:
> "variables a used" should be "variables are used".
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 3ecb5aa..639cf8a 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -395,7 +395,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  	struct gnttab_copy *copy_gop;
>  	struct netbk_rx_meta *meta;
>  	/*
> -	 * These variables a used iff get_page_ext returns true,
> +	 * These variables are used iff get_page_ext returns true,
>  	 * in which case they are guaranteed to be initialized.
>  	 */
>  	unsigned int uninitialized_var(group), uninitialized_var(idx);
