From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 09/13] xen-netfront: move grant_{ref,
 page} to struct grant
Date: Mon, 18 May 2015 16:44:52 +0100
Message-ID: <555A08F4.1030202@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-10-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:24520 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbbERPql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:46:41 -0400
In-Reply-To: <1431451117-70051-10-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> Refactors a little bit how grants are stored by moving
> grant_rx_ref/grant_tx_ref and grant_tx_page to its
> own structure, namely struct grant.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Although...

> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -87,6 +87,11 @@ struct netfront_cb {
>  /* IRQ name is queue name with "-tx" or "-rx" appended */
>  #define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
>  
> +struct grant {
> +	grant_ref_t ref;
> +	struct page *page;
> +};

Is this sort of structure (and the following patch) useful for other
frontends?

David
