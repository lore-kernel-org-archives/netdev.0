From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Tue, 18 Oct 2011 23:22:51 -0400 (EDT)
Message-ID: <20111018.232251.1022206201165745394.davem@davemloft.net>
References: <4E8CD180.5010905@candelatech.com>
	<4E8CDB9B.6010900@candelatech.com>
	<1317932911.3457.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab1JSDXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:23:01 -0400
In-Reply-To: <1317932911.3457.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Oct 2011 22:28:31 +0200

> [PATCH net-next] macvlan: handle fragmented multicast frames
> 
> Fragmented multicast frames are delivered to a single macvlan port,
> because ip defrag logic considers other samples are redundant.
> 
> Implement a defrag step before trying to send the multicast frame.
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next, thanks.
