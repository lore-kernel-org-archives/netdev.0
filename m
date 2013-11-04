From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/9] Mellanox driver updates
Date: Mon, 04 Nov 2013 16:20:58 -0500 (EST)
Message-ID: <20131104.162058.1719896205408552572.davem@davemloft.net>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab3KDVVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 16:21:01 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  3 Nov 2013 10:03:16 +0200

> This patch set from Jack Morgenstein does the following:
> 
> 1. Fix MAC/VLAN SRIOV implementation, and add wrapper functions for VLAN allocation
>    and de-allocation (patches 1-6).
> 
> 2. Implements resource quotas when running under SRIOV (patches 7-10).
>    Patch 7 is a small bug fix, and patches 8-10 implement the quotas.
> 
> Quotas are implemented per resource type for VFs and the PF, to prevent
> any entity from simply grabbing all the resources for itself and leaving
> the other entities unable to obtain such resources.
> 
> The series is against net-next commit ba48650 "ipv6: remove the unnecessary statement in find_match()"
> 
> changes from V0:
>  - dropped the 1st patch which needs to go to -stable and hence through net, 
>    not net-next   

Series applied, thanks.
