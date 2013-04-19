From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/6] net: vlan: rename NETIF_F_HW_VLAN_* feature flags
 to NETIF_F_HW_VLAN_CTAG_*
Date: Fri, 19 Apr 2013 21:07:17 +0100
Message-ID: <1366402037.2716.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
	 <1366373072-19621-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48265 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980Ab3DSUHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:07:20 -0400
In-Reply-To: <1366373072-19621-2-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:04 +0200, Patrick McHardy wrote:
> Rename the hardware VLAN acceleration features to include "CTAG" to indicate
> that they only support CTAGs. Follow up patches will introduce 802.1ad
> server provider tagging (STAGs) and require the distinction for hardware not
> supporting acclerating both.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -60,10 +60,10 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>  	[NETIF_F_IPV6_CSUM_BIT] =        "tx-checksum-ipv6",
>  	[NETIF_F_HIGHDMA_BIT] =          "highdma",
>  	[NETIF_F_FRAGLIST_BIT] =         "tx-scatter-gather-fraglist",
> -	[NETIF_F_HW_VLAN_TX_BIT] =       "tx-vlan-hw-insert",
> +	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =  "tx-vlan-ctag-hw-insert",
>  
> -	[NETIF_F_HW_VLAN_RX_BIT] =       "rx-vlan-hw-parse",
> -	[NETIF_F_HW_VLAN_FILTER_BIT] =   "rx-vlan-filter",
> +	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
> +	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
>  	[NETIF_F_VLAN_CHALLENGED_BIT] =  "vlan-challenged",
>  	[NETIF_F_GSO_BIT] =              "tx-generic-segmentation",
>  	[NETIF_F_LLTX_BIT] =             "tx-lockless",
[...]

The only stable userland identifiers for these features are their names.
So this is a userland ABI change and I don't think it's acceptable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
