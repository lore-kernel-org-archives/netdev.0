From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix a link reset issue due to
 retransmission failures
Date: Wed, 25 Mar 2015 11:46:01 -0400 (EDT)
Message-ID: <20150325.114601.1175030459168194223.davem@davemloft.net>
References: <1427278181-29389-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226AbbCYPqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:46:03 -0400
In-Reply-To: <1427278181-29389-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 25 Mar 2015 18:09:40 +0800

> When a node joins a cluster while we are transmitting a fragment
> stream over the broadcast link, it's missing the preceding fragments
> needed to build a meaningful message. As a result, the node has to
> drop it. However, as the fragment message is not acknowledged to
> its sender before it's dropped, it accidentally causes link reset
> of retransmission failure on the node.
> 
> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Tested-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.
