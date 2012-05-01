From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 01 May 2012 09:40:51 -0400 (EDT)
Message-ID: <20120501.094051.655617860554790911.davem@davemloft.net>
References: <1335863465.11396.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	hagen@jauu.net, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab2EANlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 09:41:01 -0400
In-Reply-To: <1335863465.11396.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 May 2012 11:11:05 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add ECN (Explicit Congestion Notification) marking capability to netem
> 
> tc qdisc add dev eth0 root netem drop 0.5 ecn
> 
> Instead of dropping packets, try to ECN mark them.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
