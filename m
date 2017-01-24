From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: matchall: Fix configuration race
Date: Tue, 24 Jan 2017 13:42:04 -0500 (EST)
Message-ID: <20170124.134204.1815559887565233291.davem@davemloft.net>
References: <1485161667-13929-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlxsw@mellanox.com, jiri@mellanox.com, eladr@mellanox.com,
        daniel@iogearbox.net, jhs@mojatatu.com, netdev@vger.kernel.org
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXSmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:42:05 -0500
In-Reply-To: <1485161667-13929-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Mon, 23 Jan 2017 10:54:27 +0200

> In the current version, the matchall internal state is split into two
> structs: cls_matchall_head and cls_matchall_filter. This makes little
> sense, as matchall instance supports only one filter, and there is no
> situation where one exists and the other does not. In addition, that led
> to some races when filter was deleted while packet was processed.
> 
> Unify that two structs into one, thus simplifying the process of matchall
> creation and deletion. As a result, the new, delete and get callbacks have
> a dummy implementation where all the work is done in destroy and change
> callbacks, as was done in cls_cgroup.
> 
> Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

This doesn't apply cleanly to the net tree, please respin.
