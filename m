From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: make ops structs const
Date: Thu, 5 Jan 2012 08:44:46 +0000
Message-ID: <1325753087.25206.336.camel@zakaz.uk.xensource.com>
References: <20120104135658.0347211f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:54739 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179Ab2AEIos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 03:44:48 -0500
In-Reply-To: <20120104135658.0347211f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-01-04 at 21:56 +0000, Stephen Hemminger wrote:
> All tables of function pointers should be const to make hacks
> more difficult. Compile tested only.

I also eyeballed for any writes to these structs and couldn't find one.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> 
> ---
> Patch against net-next
> 
> --- a/drivers/net/xen-netback/interface.c	2011-12-07 10:54:19.232282492 -0800
> +++ b/drivers/net/xen-netback/interface.c	2012-01-04 13:16:04.414052721 -0800
> @@ -223,7 +223,7 @@ static void xenvif_get_strings(struct ne
>  	}
>  }
>  
> -static struct ethtool_ops xenvif_ethtool_ops = {
> +static const struct ethtool_ops xenvif_ethtool_ops = {
>  	.get_link	= ethtool_op_get_link,
>  
>  	.get_sset_count = xenvif_get_sset_count,
> @@ -231,7 +231,7 @@ static struct ethtool_ops xenvif_ethtool
>  	.get_strings = xenvif_get_strings,
>  };
>  
> -static struct net_device_ops xenvif_netdev_ops = {
> +static const struct net_device_ops xenvif_netdev_ops = {
>  	.ndo_start_xmit	= xenvif_start_xmit,
>  	.ndo_get_stats	= xenvif_get_stats,
>  	.ndo_open	= xenvif_open,
