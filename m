From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bridge: per-vlan stats
Date: Fri, 29 Apr 2016 15:33:26 -0400 (EDT)
Message-ID: <20160429.153326.652947047579122837.davem@davemloft.net>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, jhs@mojatatu.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbcD2Td2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 15:33:28 -0400
In-Reply-To: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 28 Apr 2016 17:52:46 +0200

> This set adds support for bridge per-vlan statistics.

Between the counter bumps in fast paths and new levels of pointer
indirection in order to RCU things, I have to agree with Stephen
that this new overhead is really pushing it.

All of this new overhead contributes to the transactional overhead
for every single packet.

Sorry I'm not going to apply this for now, unless you can come up
with something significantly cheaper.

Thanks.
