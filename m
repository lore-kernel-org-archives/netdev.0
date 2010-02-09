From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Tue, 09 Feb 2010 15:17:52 -0800 (PST)
Message-ID: <20100209.151752.234323076.davem@davemloft.net>
References: <20100205062131.20910.10580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754163Ab0BIXRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 18:17:39 -0500
In-Reply-To: <20100205062131.20910.10580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 04 Feb 2010 22:21:49 -0800

> +struct ethtool_rx_ntuple_flow_spec_container {
> +	struct ethtool_rx_ntuple_flow_spec fs;
> +	struct list_head list;
> +};
> +
> +struct ethtool_rx_ntuple_list {
> +#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
> +#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
> +	struct list_head	list;
> +	int			count;
> +};

These are kernel private data structures, please therefore put them in
the __KERNEL__ protected area of ethtool.h

Thanks.
