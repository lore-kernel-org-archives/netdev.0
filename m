From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: Change possible SYN flooding messages
Date: Thu, 15 Sep 2011 15:06:56 -0400 (EDT)
Message-ID: <20110915.150656.1806555644701740410.davem@davemloft.net>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
	<1314710504.2935.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934330Ab1IOTHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:07:03 -0400
In-Reply-To: <1314710504.2935.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Aug 2011 15:21:44 +0200

> "Possible SYN flooding on port xxxx " messages can fill logs on servers.
> 
> Change logic to log the message only once per listener, and add two new
> SNMP counters to track :
> 
> TCPReqQFullDoCookies : number of times a SYNCOOKIE was replied to client
> 
> TCPReqQFullDrop : number of times a SYN request was dropped because
> syncookies were not enabled.
> 
> Based on a prior patch from Tom Herbert, and suggestions from David.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
