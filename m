From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 5/6] xen/netback: Enable netback on HVM guests
Date: Mon, 24 Oct 2011 10:31:08 +0100
Message-ID: <1319448669.3385.161.camel@zakaz.uk.xensource.com>
References: <1318969583-23902-1-git-send-email-dgdegra@tycho.nsa.gov>
	 <1319124957-32269-1-git-send-email-dgdegra@tycho.nsa.gov>
	 <1319124957-32269-6-git-send-email-dgdegra@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	<netdev@vger.kernel.org>
To: Daniel De Graaf <dgdegra@tycho.nsa.gov>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:41105 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992Ab1JXJbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 05:31:10 -0400
In-Reply-To: <1319124957-32269-6-git-send-email-dgdegra@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-20 at 16:35 +0100, Daniel De Graaf wrote:
> Signed-off-by: Daniel De Graaf <dgdegra@tycho.nsa.gov>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Normally netback patches would go in via the networking subsystem
maintainer's tree but since this depends on core Xen patches from this
series and is unlikely to conflict with anything in the net-next tree I
suspect it would make more sense for Konrad to take this one.

David (Miller) does that work for you?

Ian.

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 3af2924..9d80f99 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1626,7 +1626,7 @@ static int __init netback_init(void)
>  	int rc = 0;
>  	int group;
>  
> -	if (!xen_pv_domain())
> +	if (!xen_domain())
>  		return -ENODEV;
>  
>  	xen_netbk_group_nr = num_online_cpus();
