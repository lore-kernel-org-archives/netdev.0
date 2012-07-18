From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: refine SYN handling in
 tcp_validate_incoming
Date: Wed, 18 Jul 2012 09:32:44 -0700 (PDT)
Message-ID: <20120718.093244.874089024352388424.davem@davemloft.net>
References: <CAGK4HS8MvP6L5Rvy4wJx2KhdTSSHfP7YPT44e9mrV_vsBZJ9jQ@mail.gmail.com>
	<1342563706.2626.1228.camel@edumazet-glaptop>
	<1342564170.2626.1243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	kkiran@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014Ab2GRQcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:32:45 -0400
In-Reply-To: <1342564170.2626.1243.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 00:29:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Followup of commit 0c24604b68fc (tcp: implement RFC 5961 4.2)
> 
> As reported by Vijay Subramanian, we should send a challenge ACK
> instead of a dup ack if a SYN flag is set on a packet received out of
> window.
> 
> This permits the ratelimiting to work as intended, and to increase
> correct SNMP counters.
> 
> Suggested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
