From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net/sched: cls_matchall: Fix error path
Date: Tue, 03 Jan 2017 18:59:01 -0500 (EST)
Message-ID: <20170103.185901.448467338156956349.davem@davemloft.net>
References: <1483464024-25745-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, eladr@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58704 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753308AbdACX7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:59:38 -0500
In-Reply-To: <1483464024-25745-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Tue,  3 Jan 2017 19:20:24 +0200

> Fix several error paths in matchall:
>  - Release reference to actions in case the hardware fails offloading
>    (relevant to skip_sw only)
>  - Fix error path in case tcf_exts initialization/validation fail
> 
> Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> ---
> v1->v2:
>  - Add check for tcf_exts_init return code and fix error path for it too

Applied, thank you.
