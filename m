From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add accessor to vlan egress map
Date: Thu, 07 Nov 2013 19:10:22 -0500 (EST)
Message-ID: <20131107.191022.2253677077671640570.davem@davemloft.net>
References: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sean.hefty@intel.com,
	eyalpe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717Ab3KHAKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:10:23 -0500
In-Reply-To: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  6 Nov 2013 15:37:22 +0200

> This series adds on the work done through commits d4a968658c "net/route: export 
> symbol ip_tos2prio" and 366cddb40 "IB/rdma_cm: TOS <=> UP mapping for IBoE".
> 
> When vlans are used, the IBoE stack needs to inherit the egress map
> which is configured on the vlan device. For that end, we provide a
> read-only access method and call it from the RDMA-CM.

Looks good, series applied.
