From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: make proxy arp configurable
Date: Fri, 31 Oct 2014 12:21:33 -0400 (EDT)
Message-ID: <20141031.122133.1697556792716394439.davem@davemloft.net>
References: <20141030200942.5a531e34@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kyeyoonp@codeaurora.org, netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757339AbaJaQVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 12:21:38 -0400
In-Reply-To: <20141030200942.5a531e34@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Thu, 30 Oct 2014 20:09:42 -0700

> @@ -60,3 +60,19 @@ config BRIDGE_VLAN_FILTERING
>  	  Say N to exclude this support and reduce the binary size.
>  
>  	  If unsure, say Y.
> +
> +config BRIDGE_ARP_PROXY
> +	bool "ARP proxying"
> +	depends on BRIDGE
> +	depends on INET
> +	default y
> +	---help---
> +	  If you say Y here, then the Ethernet bridge to keep track of
> +	  the hardware address to IP address mapping.
> +
> +	  It is most useful when used as a wireless AP.
> +
> +	  Say N to exclude this support and reduce the binary size.
> +
> +	  If unsure, say Y.
> +

Please do not ever add empty lines at the end of files, GIT warns
about this when I try to apply your patch.
