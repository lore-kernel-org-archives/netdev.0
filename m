From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_hfsc: report backlog information
Date: Fri, 23 Dec 2011 16:52:11 -0500 (EST)
Message-ID: <20111223.165211.2284691649192041978.davem@davemloft.net>
References: <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324653560.2223.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jsullivan@opensourcedevel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab1LWVwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 16:52:18 -0500
In-Reply-To: <1324653560.2223.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Dec 2011 16:19:20 +0100

> Add backlog (byte count) information in hfsc classes and qdisc, so that
> "tc -s" can report it to user, instead of 0 values :
> 
> qdisc hfsc 1: root refcnt 6 default 20 
>  Sent 45141660 bytes 30545 pkt (dropped 0, overlimits 91751 requeues 0) 
>  rate 1492Kbit 126pps backlog 103226b 74p requeues 0 
> ...
> class hfsc 1:20 parent 1:1 leaf 1201: rt m1 0bit d 0us m2 400000bit ls m1 0bit d 0us m2 200000bit 
>  Sent 49534912 bytes 33519 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 81822b 56p requeues 0 
>  period 23 work 49451576 bytes rtwork 13277552 bytes level 0 
> ...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
