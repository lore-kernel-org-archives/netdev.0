From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_matchall: Fix error path
Date: Tue, 03 Jan 2017 11:08:07 -0500 (EST)
Message-ID: <20170103.110807.1415814934069793893.davem@davemloft.net>
References: <1483458422-13607-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, eladr@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934911AbdACQIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:08:09 -0500
In-Reply-To: <1483458422-13607-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Tue,  3 Jan 2017 17:47:02 +0200

> Fix several error paths in matchall:
>  - Release reference to actions in case the hardware fails offloading
>    (relevant to skip_sw only)
>  - Fix error path in case tcf_exts initialization fails
> 
> Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Nothing is checking the tcf_exts_init() return value for errors either,
and I think you should fix this alongside these release problems at the
same time.

Thanks.
