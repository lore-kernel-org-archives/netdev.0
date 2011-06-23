From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net:  Support RXFCS feature flag.
Date: Fri, 24 Jun 2011 00:22:08 +0100
Message-ID: <1308871328.3093.1020.camel@localhost>
References: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
	 <1308870819-15938-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38507 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471Ab1FWXWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 19:22:12 -0400
In-Reply-To: <1308870819-15938-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 16:13 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> When set, this causes the Ethernet FCS to be appended
> to the end of the skb.
> 
> Useful for sniffing packets.
[...]
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -347,6 +347,7 @@ struct ethtool_perm_addr {
>   * flag differs from the read-only value.
>   */
>  enum ethtool_flags {
> +	ETH_FLAG_RXFCS		= (1 << 0),	/* Append FCS to skb */
>  	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
>  	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
>  	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
[...]

No, all new features should be accessed through the
ETHTOOL_{G,S}FEATURES commands only.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

