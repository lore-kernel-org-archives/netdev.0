From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 net-next] sunvnet: edge-case/race-conditions bug
 fixes
Date: Mon, 10 Nov 2014 21:06:15 -0500 (EST)
Message-ID: <20141110.210615.1017331081770916209.davem@davemloft.net>
References: <20141109014143.GB31217@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaKKCGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:06:19 -0500
In-Reply-To: <20141109014143.GB31217@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat, 8 Nov 2014 20:41:43 -0500

> This patch series contains fixes for race-conditions in sunvnet,
> that can encountered when there is a difference in latency between
> producer and consumer.
> 
> Patch 1 addresses a case when the STOPPED LDC ack from a peer is
> processed before vnet_start_xmit can finish updating the dr->prod
> state. 
> 
> Patch 2 fixes the edge-case when outgoing data and incoming
> stopped-ack cross each other in flight. 
> 
> Patch 3 adds a missing rcu_read_unlock(), found by code-inspection.

Series applied, thanks.
