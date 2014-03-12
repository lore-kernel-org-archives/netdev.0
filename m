From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/7] mlx4: Add SRIOV support for RoCE
Date: Wed, 12 Mar 2014 15:57:58 -0400 (EDT)
Message-ID: <20140312.155758.2303597747142158471.davem@davemloft.net>
References: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbaCLT6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:58:00 -0400
In-Reply-To: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 12 Mar 2014 12:00:36 +0200

> This series adds SRIOV support for RoCE (RDMA over Ethernet) to the mlx4 driver.
> 
> The patches are against net-next, as of commit 2d8d40a "pkt_sched: fq:
> do not hold qdisc lock while allocating memory"
 ...
> changes from V1:
>  - addressed feedback from Dave on patch #3 and changed get_real_sgid_index()
>    to be called fill_in_real_sgid_index() and be a void  function.
>  - removed some checkpatch warnings on long lines
> 
> changes from V0:
>   - always check the return code of mlx4_get_roce_gid_from_slave().
>     The call we fixed is introduced in patch #1 and later removed by 
>     patch #3 that allows guests to have multiple GIDS. The 1..3 
>     separation was done for proper division of patches to logical changes.

Series applied, thanks Or.
