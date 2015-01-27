From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add tipc support
Date: Mon, 26 Jan 2015 17:04:41 -0800 (PST)
Message-ID: <20150126.170441.724106999176865818.davem@davemloft.net>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
	<1421943032-29924-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757396AbbA0BEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:04:42 -0500
In-Reply-To: <1421943032-29924-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 22 Jan 2015 17:10:32 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> The flows are hashed on the sending node address, which allows us
> to spread out the TIPC link processing to RPS enabled cores. There
> is no point to include the destination address in the hash as that
> will always be the same for all inbound links. We have experimented
> with a 3-tuple hash over [srcnode, sport, dport], but this showed to
> give slightly lower performance because of increased lock contention
> when the same link was handled by multiple cores.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
