From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 0/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 21 Jan 2014 18:05:35 -0800 (PST)
Message-ID: <20140121.180535.1584624943804420689.davem@davemloft.net>
References: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, edumazet@google.com,
	herbert@gondor.apana.org.au, yanb@mellanox.com,
	shlomop@mellanox.com, therbert@google.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbaAVCFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 21:05:38 -0500
In-Reply-To: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 20 Jan 2014 13:59:18 +0200

> This series adds GRO handlers for protocols that do UDP encapsulation, with the
> intent of being able to coalesce packets which encapsulate packets belonging to
> the same TCP session.
> 
> For GRO purposes, the destination UDP port takes the role of the ether type
> field in the ethernet header or the next protocol in the IP header.
> 
> The UDP GRO handler will only attempt to coalesce packets whose destination
> port is registered to have gro handler.
> 
> The patches done against net-next 75e4364f67 "net: stmmac: fix NULL pointer 
> dereference in stmmac_get_tx_hwtstamp"

Looks good, series applied, thanks!
