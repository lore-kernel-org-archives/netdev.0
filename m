From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use net_eq() in INET_MATCH and INET_TW_MATCH
Date: Fri, 21 Nov 2008 15:49:27 -0800 (PST)
Message-ID: <20081121.154927.230877589.davem@davemloft.net>
References: <492736BD.5040508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56054
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbYKUXt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:49:26 -0500
In-Reply-To: <492736BD.5040508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Nov 2008 23:31:25 +0100

> We can avoid some useless instructions if !CONFIG_NET_NS
> 
> Because of RCU, we use INET_MATCH or INET_TW_MATCH twice for the found socket, so thats six instructions less per
> incoming TCP packet.
> 
> Yet another tbench speedup :)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
