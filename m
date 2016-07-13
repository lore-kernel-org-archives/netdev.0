From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] Mellanox 100G mlx5 Bulk flow statistics
 and SRIOV TC offloads
Date: Wed, 13 Jul 2016 11:46:25 -0700 (PDT)
Message-ID: <20160713.114625.345817834403177179.davem@davemloft.net>
References: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com,
	jiri@mellanox.com, gospo@cumulusnetworks.com,
	jesse.brandeburg@intel.com, john.r.fastabend@intel.com,
	amir@vadai.me
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbcGMSqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 14:46:51 -0400
In-Reply-To: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 13 Jul 2016 00:28:56 +0300

> This series from Amir and Or deals with two enhancements for the mlx5 TC offloads.
> 
> The 1st two patches add bulk reading of flow counters. Few bulk counter queries are
> used instead of issuing thousands firmware commands per second to get statistics of all
> flows set to HW.
> 
> The next patches add TC based SRIOV offloading to mlx5, as a follow up for the e-switch
> offloads mode and the VF representors. When the e-switch is set to the (new) "offloads"
> mode, we can now offload TC/flower drop and forward rules, the forward action we offload
> is TC mirred/redirect.
> 
> The above is done by the VF representor netdevices exporting the setup_tc ndo where from
> there we're re-using and enhancing the existing mlx5 TC offloads sub-module which now
> works for both the NIC and the SRIOV cases.
> 
> The series is applied on top d3fc0353f7c7 ('ipv4: af_inet: make it explicitly non-modular')
> and it has no merge issues with the on-going net submission ('mlx5 tx timeout watchdog fixes')

Series applied, thanks.
