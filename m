From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] tipc: fix broken tipc_poll() function
Date: Sat, 21 Oct 2017 12:27:36 +0100 (WEST)
Message-ID: <20171021.122736.1424744821329915425.davem@davemloft.net>
References: <1508424124-1748-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdJUL1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 07:27:40 -0400
In-Reply-To: <1508424124-1748-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 19 Oct 2017 16:42:04 +0200

> In commit ae236fb208a6 ("tipc: receive group membership events via
> member socket") we broke the tipc_poll() function by checking the
> state of the receive queue before the call to poll_sock_wait(), while
> relying that state afterwards, when it might have changed.
> 
> We restore this in this commit.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
