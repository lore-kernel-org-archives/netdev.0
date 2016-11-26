From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix compatibility bug in link monitoring
Date: Fri, 25 Nov 2016 20:06:50 -0500 (EST)
Message-ID: <20161125.200650.944480941058818858.davem@davemloft.net>
References: <1479953126-3552-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amar.nv005@gmail.com,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZBGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:06:54 -0500
In-Reply-To: <1479953126-3552-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 23 Nov 2016 21:05:26 -0500

> commit 817298102b0b ("tipc: fix link priority propagation") introduced a
> compatibility problem between TIPC versions newer than Linux 4.6 and
> those older than Linux 4.4. In versions later than 4.4, link STATE
> messages only contain a non-zero link priority value when the sender
> wants the receiver to change its priority. This has the effect that the
> receiver resets itself in order to apply the new priority. This works
> well, and is consistent with the said commit.
> 
> However, in versions older than 4.4 a valid link priority is present in
> all sent link STATE messages, leading to cyclic link establishment and
> reset on the 4.6+ node.
> 
> We fix this by adding a test that the received value should not only
> be valid, but also differ from the current value in order to cause the
> receiving link endpoint to reset.
> 
> Reported-by: Amar Nv <amar.nv005@gmail.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
