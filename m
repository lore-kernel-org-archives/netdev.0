From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: add neighbor monitoring framework
Date: Wed, 15 Jun 2016 14:07:22 -0700 (PDT)
Message-ID: <20160615.140722.735826371979735548.davem@davemloft.net>
References: <1465865182-10461-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbcFOVHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:07:24 -0400
In-Reply-To: <1465865182-10461-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 13 Jun 2016 20:46:22 -0400

> TIPC based clusters are by default set up with full-mesh link
> connectivity between all nodes. Those links are expected to provide
> a short failure detection time, by default set to 1500 ms. Because
> of this, the background load for neighbor monitoring in an N-node
> cluster increases with a factor N on each node, while the overall
> monitoring traffic through the network infrastructure increases at
> a ~(N * (N - 1)) rate. Experience has shown that such clusters don't
> scale well beyond ~100 nodes unless we significantly increase failure
> discovery tolerance.
> 
> This commit introduces a framework and an algorithm that drastically
> reduces this background load, while basically maintaining the original
> failure detection times across the whole cluster. Using this algorithm,
> background load will now grow at a rate of ~(2 * sqrt(N)) per node, and
> at ~(2 * N * sqrt(N)) in traffic overhead. As an example, each node will
> now have to actively monitor 38 neighbors in a 400-node cluster, instead
> of as before 399.
> 
> This "Overlapping Ring Supervision Algorithm" is completely distributed
> and employs no centralized or coordinated state. It goes as follows:
 ...
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
