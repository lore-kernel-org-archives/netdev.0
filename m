From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_teql: Use net_device internal stats
Date: Tue, 19 May 2009 15:16:46 -0700 (PDT)
Message-ID: <20090519.151646.176403748.davem@davemloft.net>
References: <4A120C8B.80108@cosmosbay.com>
	<20090518.193438.158960584.davem@davemloft.net>
	<4A1246ED.3080203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754197AbZESWQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:16:48 -0400
In-Reply-To: <4A1246ED.3080203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 19 May 2009 07:43:09 +0200

> [PATCH] sch_teql: Use net_device internal stats
> 
> We can slightly reduce size of teqlN structure, not duplicating stats structure
> in teql_master but using stats field from net_device.stats for tx_errors and from 
> netdev_queue for tx_bytes/tx_packets/tx_dropped values.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks!
