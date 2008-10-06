From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net: define feature flags for FCoE offloads
Date: Mon, 06 Oct 2008 23:37:22 +0100
Message-ID: <1223332642.3984.94.camel@achroite>
References: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com>
	 <20081006220926.3308.48505.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@open-fcoe.org
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:52604 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbYJFWh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:37:27 -0400
In-Reply-To: <20081006220926.3308.48505.stgit@zyfc9ini.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-06 at 15:09 -0700, Yi Zou wrote:
> From: Chris Leech <christopher.leech@intel.com>
> 
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> ---
> 
>  include/linux/netdevice.h |    3 +++
>  include/linux/skbuff.h    |    2 ++
>  2 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 9cfd20b..ef65927 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -522,6 +522,8 @@ struct net_device
>  #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
>  #define NETIF_F_LRO		32768	/* large receive offload */
>  
> +#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
> +
>  	/* Segmentation offload features */
>  #define NETIF_F_GSO_SHIFT	16
>  #define NETIF_F_GSO_MASK	0xffff0000
[...]

NETIF_F_FCOE_CRC shouldn't be included in NETIF_F_GSO_MASK.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

