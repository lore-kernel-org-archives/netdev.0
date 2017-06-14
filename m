From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Fix an off by one bug
Date: Wed, 14 Jun 2017 15:20:29 -0400 (EDT)
Message-ID: <20170614.152029.1673534481673725513.davem@davemloft.net>
References: <20170614091009.GA29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdFNTUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:20:31 -0400
In-Reply-To: <20170614091009.GA29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 14 Jun 2017 12:10:10 +0300

> The p_l2_info->pp_qid_usage[] array has "p_l2_info->queues" elements so
> the > here should be a >= or we write beyond the end of the array.
> 
> Fixes: bbe3f233ec5e ("qed: Assign a unique per-queue index to queue-cid")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
