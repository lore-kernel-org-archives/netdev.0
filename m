From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: avoid drop_monitor false positives
Date: Fri, 07 Sep 2012 14:18:36 -0400 (EDT)
Message-ID: <20120907.141836.1597780399266624583.davem@davemloft.net>
References: <1346999826.2484.252.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab2IGSSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:18:39 -0400
In-Reply-To: <1346999826.2484.252.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Sep 2012 08:37:06 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> igmp should call consume_skb() for all correctly processed packets,
> to avoid false dropwatch/drop_monitor false positives.
> 
> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
