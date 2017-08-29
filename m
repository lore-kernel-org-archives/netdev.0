From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: permit bond slave as bearer
Date: Tue, 29 Aug 2017 15:10:10 -0700 (PDT)
Message-ID: <20170829.151010.576756367251017558.davem@davemloft.net>
References: <1503935822-20445-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40074 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2WKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:10:11 -0400
In-Reply-To: <1503935822-20445-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Mon, 28 Aug 2017 17:57:02 +0200

> For a bond slave device as a tipc bearer, the dev represents the bond
> interface and orig_dev represents the slave in tipc_l2_rcv_msg().
> Since we decode the tipc_ptr from bonding device (dev), we fail to
> find the bearer and thus tipc links are not established.
> 
> In this commit, we register the tipc protocol callback per device and
> look for tipc bearer from both the devices.
> 
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied.
