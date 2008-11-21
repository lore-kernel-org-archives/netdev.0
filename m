From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the	kernel and ixgbe driver
Date: Fri, 21 Nov 2008 14:06:52 +0100
Message-ID: <4926B26C.7010200@trash.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52659 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbYKUNHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 08:07:00 -0500
In-Reply-To: <20081121020055.22180.24154.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This adds support for Data Center Bridging (DCB) features in the ixgbe driver and adds an rtnetlink interface for configuring DCB to the kernel.  The DCB feature support included are Priority Grouping (PG) - which allows bandwidth guarantees to be allocated to groups to traffic based on the 802.1q priority, and Priority Based Flow Control (PFC) - which introduces a new MAC control PAUSE frame which works at granularity of the 802.1p priority instead of the link (IEEE 802.3x).
> 
> --- /dev/null
> +++ b/net/dcb/Kconfig
> @@ -0,0 +1,12 @@
> +config DCB
> +        tristate "Data Center Bridging support"

A help text would be nice to have.

> +
> +config DCBNL
> +	bool "Data Center Bridging netlink interface support"
> +	depends on DCB
> +	default n
> +	---help---
> +	  This option turns on the netlink interface
> +	  (dcbnl) for Data Center Bridging capable devices.
> +
> +	  If unsure, say N.
