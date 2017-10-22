From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] tipc: refactor tipc_sk_timeout() function
Date: Sun, 22 Oct 2017 02:38:17 +0100 (WEST)
Message-ID: <20171022.023817.1244689722862305095.davem@davemloft.net>
References: <1508491292-5333-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932292AbdJVBiV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:38:21 -0400
In-Reply-To: <1508491292-5333-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 20 Oct 2017 11:21:32 +0200

> The function tipc_sk_timeout() is more complex than necessary, and
> even seems to contain an undetected bug. At one of the occurences
> where we renew the timer we just order it with (HZ / 20), instead
> of (jiffies + HZ / 20);
> 
> In this commit we clean up the function.
> 
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
