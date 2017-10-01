From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: use only positive error codes in
 messages
Date: Sun, 01 Oct 2017 04:04:34 +0100 (WEST)
Message-ID: <20171001.040434.1155203728534988379.davem@davemloft.net>
References: <1506672174-26962-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
        parthasarathy.bhuvaragan@gmail.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751204AbdJADEg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 23:04:36 -0400
In-Reply-To: <1506672174-26962-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Fri, 29 Sep 2017 10:02:54 +0200

> In commit e3a77561e7d32 ("tipc: split up function tipc_msg_eval()"),
> we have updated the function tipc_msg_lookup_dest() to set the error
> codes to negative values at destination lookup failures. Thus when
> the function sets the error code to -TIPC_ERR_NO_NAME, its inserted
> into the 4 bit error field of the message header as 0xf instead of
> TIPC_ERR_NO_NAME (1). The value 0xf is an unknown error code.
> 
> In this commit, we set only positive error code.
> 
> Fixes: e3a77561e7d32 ("tipc: split up function tipc_msg_eval()")
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied and queued up for -stable, thanks.
