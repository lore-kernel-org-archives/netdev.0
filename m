From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: out_qlen should be updated when pruning
 unsent queue
Date: Tue, 21 Mar 2017 18:32:48 -0700 (PDT)
Message-ID: <20170321.183248.1571202262140371999.davem@davemloft.net>
References: <16cb6e6d2ef47481123bc3ff1b99e8abf5334d14.1489838639.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdCVBmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:42:22 -0400
In-Reply-To: <16cb6e6d2ef47481123bc3ff1b99e8abf5334d14.1489838639.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 18 Mar 2017 20:03:59 +0800

> This patch is to fix the issue that sctp_prsctp_prune_sent forgot
> to update q->out_qlen when removing a chunk from unsent queue.
> 
> Fixes: 8dbdf1f5b09c ("sctp: implement prsctp PRIO policy")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
