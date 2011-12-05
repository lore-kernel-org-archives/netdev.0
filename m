From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] netback: Fix alert message.
Date: Mon, 5 Dec 2011 16:58:45 +0000
Message-ID: <1323104325.23681.22.camel@zakaz.uk.xensource.com>
References: <1323104264-3601-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:56578 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513Ab1LEQ6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 11:58:47 -0500
In-Reply-To: <1323104264-3601-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-05 at 16:57 +0000, Wei Liu wrote:
> The original message in netback_init was 'kthread_run() fails', which should be
> 'kthread_create() fails'.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks!

Ian.

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 1ae270e..15e332d 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1668,7 +1668,7 @@ static int __init netback_init(void)
>  					     "netback/%u", group);
>  
>  		if (IS_ERR(netbk->task)) {
> -			printk(KERN_ALERT "kthread_run() fails at netback\n");
> +			printk(KERN_ALERT "kthread_create() fails at netback\n");
>  			del_timer(&netbk->net_timer);
>  			rc = PTR_ERR(netbk->task);
>  			goto failed_init;
