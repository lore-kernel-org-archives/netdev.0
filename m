From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: remove nested rcu_read_lock/unlock
Date: Fri, 01 Aug 2014 21:12:09 +0200
Message-ID: <1406920329.28434.28.camel@localhost>
References: <53DB2D04.6030909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55806 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754697AbaHATMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 15:12:12 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id 067C622F78
	for <netdev@vger.kernel.org>; Fri,  1 Aug 2014 15:12:12 -0400 (EDT)
In-Reply-To: <53DB2D04.6030909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-08-01 at 14:00 +0800, Duan Jiong wrote:
> ip_local_deliver_finish() already have a rcu_read_lock/unlock, so
> the rcu_read_lock/unlock is unnecessary.
> 
> See the stack below:
> ip_local_deliver_finish
> 	|
> 	|
> 	->icmp_rcv
> 		|
> 		|
> 		->icmp_socket_deliver
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Cool, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
