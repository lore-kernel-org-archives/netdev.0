From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 0/8] net/mlx4: Add support to SRIOV VF
 management ndo calls
Date: Fri, 26 Apr 2013 23:30:21 -0400 (EDT)
Message-ID: <20130426.233021.485920150293396881.davem@davemloft.net>
References: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab3D0DaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 23:30:23 -0400
In-Reply-To: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 25 Apr 2013 18:22:22 +0300

> This series adds support for the SRIOV ndo_set_vf callbacks to the mlx4 driver.
> 
> Series done against the net-next tree as of commit 37fe0660981d7a "net: 
> fix address check in rtnl_fdb_del"
> 
> We have successfully tested the series on net-next, except for getting
> the VF link info issue I have reported earlier today on netdev, we 
> see the problem for both ixgbe and mlx4 VFs. Just to make sure get 
> VF config is working OK with patch #6 - we have run it over 3.8.8 too.
> 
> We added to the V1 series two patches that disable HW timestamping
> when running over a VF, as this isn't supported yet.

Series applied, thanks a lot!
