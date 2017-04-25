From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/2] tipc: fix socket flow control accounting
 error at tipc_send_stream
Date: Tue, 25 Apr 2017 11:45:52 -0400 (EDT)
Message-ID: <20170425.114552.1090114347611764286.davem@davemloft.net>
References: <1493038843-30621-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950564AbdDYPpy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:45:54 -0400
In-Reply-To: <1493038843-30621-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Mon, 24 Apr 2017 15:00:42 +0200

> Until now in tipc_send_stream(), we return -1 when the socket
> encounters link congestion even if the socket had successfully
> sent partial data. This is incorrect as the application resends
> the same the partial data leading to data corruption at
> receiver's end.
> 
> In this commit, we return the partially sent bytes as the return
> value at link congestion.
> 
> Fixes: 10724cc7bb78 ("tipc: redesign connection-level flow control")
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Both patches #1 and #2 applied, thanks.
