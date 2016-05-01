From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: set 'active' state correctly for
 first established link
Date: Sun, 01 May 2016 19:40:49 -0400 (EDT)
Message-ID: <20160501.194049.1009552595420088885.davem@davemloft.net>
References: <1461888968-26879-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcEAXkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:40:52 -0400
In-Reply-To: <1461888968-26879-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 28 Apr 2016 20:16:08 -0400

> When we are displaying statistics for the first link established between
> two peers, it will always be presented as STANDBY although it in reality
> is ACTIVE.
> 
> This happens because we forget to set the 'active' flag in the link
> instance at the moment it is established. Although this is a bug, it only
> has impact on the presentation view of the link, not on its actual
> functionality.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
