From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix bug in socket reception function
Date: Sun, 08 Feb 2015 13:09:50 -0800 (PST)
Message-ID: <20150208.130950.2302140482089254354.davem@davemloft.net>
References: <1423411850-2594-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758966AbbBHVJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 16:09:51 -0500
In-Reply-To: <1423411850-2594-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sun,  8 Feb 2015 11:10:50 -0500

> In commit c637c1035534867b85b78b453c38c495b58e2c5a ("tipc: resolve race
> problem at unicast message reception") we introduced a time limit
> for how long the function tipc_sk_eneque() would be allowed to execute
> its loop. Unfortunately, the test for when this limit is passed was put
> in the wrong place, resulting in a lost message when the test is true.
> 
> We fix this by moving the test to before we dequeue the next buffer
> from the input queue.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
