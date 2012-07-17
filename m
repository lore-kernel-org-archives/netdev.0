From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add OFO snmp counters
Date: Mon, 16 Jul 2012 22:12:32 -0700 (PDT)
Message-ID: <20120716.221232.1581983057864739720.davem@davemloft.net>
References: <1342438896.23494.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab2GQFMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:12:35 -0400
In-Reply-To: <1342438896.23494.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Jul 2012 13:41:36 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add three SNMP TCP counters, to better track TCP behavior
> at global stage (netstat -s), when packets are received
> Out Of Order (OFO)
> 
> TCPOFOQueue : Number of packets queued in OFO queue
> 
> TCPOFODrop  : Number of packets meant to be queued in OFO
>               but dropped because socket rcvbuf limit hit.
> 
> TCPOFOMerge : Number of packets in OFO that were merged with
>               other packets.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
