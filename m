From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4_core fixes
Date: Thu, 01 Aug 2013 15:10:15 -0700 (PDT)
Message-ID: <20130801.151015.2088233583213655382.davem@davemloft.net>
References: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565Ab3HAWKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:10:16 -0400
In-Reply-To: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  1 Aug 2013 19:54:59 +0300

> Patch #1 complements commit ef96f7d46ad "net/mlx4_en: Handle unassigned VF MAC
> address correctly" which took care of the VM side of things. It follows the
> approach taken by the ixgbevf (e1941a7 "ixgbevf: Adjust to handle unassigned
> MAC address from PF") and bnx2x (e09b74d01 "bnx2x: Zero VFs starting MACs")
> drivers too, so users will experience unified approach across vendors.
> 
> Would be happy to see both patches land in -stable for 3.10.y - do you 
> want to handle that through the peridioc batches you send to Greg?
> 
> The patches were done against the net tree, commit e44892c1b "igb: 
> fix vlan filtering in promisc mode when not in VT mode"

Applied and queued up for -stable, thanks.
