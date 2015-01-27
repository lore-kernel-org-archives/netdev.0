From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tipc: fix excessive network event logging
Date: Mon, 26 Jan 2015 17:04:36 -0800 (PST)
Message-ID: <20150126.170436.335819853373283571.davem@davemloft.net>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbbA0BEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:04:37 -0500
In-Reply-To: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 22 Jan 2015 17:10:31 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If a large number of namespaces is spawned on a node and TIPC is
> enabled in each of these, the excessive printk tracing of network
> events will cause the system to grind down to a near halt.
> The traces are still of debug value, so instead of removing them
> completely we fix it by changing the link state and node availability
> logging debug traces.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.
