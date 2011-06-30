From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 4/4] xen/netback: Add module alias for autoloading
Date: Thu, 30 Jun 2011 12:39:54 -0400
Message-ID: <20110630163954.GE5771__14421.9124144458$1309452086$gmane$org@dumpdata.com>
References: <20110629124132.GD31038@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Bastian Blank <waldi@debian.org>, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org,
	Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org,
	netdev@vger.ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:19405 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab1F3QlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 12:41:00 -0400
Content-Disposition: inline
In-Reply-To: <20110629124132.GD31038@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 02:41:32PM +0200, Bastian Blank wrote:
> Add xen-backend:vif module alias to the xen-netback module. This allows
> automatic loading of the module.

Dave,

Could you queue this up for 3.1 please? I've the other two patches in my
tree for 3.1 and the block patch ready for Jens.

> 
> Signed-off-by: Bastian Blank <waldi@debian.org>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/net/xen-netback/netback.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 0e4851b..fd00f25 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1743,3 +1743,4 @@ failed_init:
>  module_init(netback_init);
>  
>  MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_ALIAS("xen-backend:vif");
> -- 
> 1.7.5.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
