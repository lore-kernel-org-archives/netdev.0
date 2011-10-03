From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: report ECN_SEEN in tcp_info
Date: Mon, 03 Oct 2011 14:01:31 -0400 (EDT)
Message-ID: <20111003.140131.2250612091091726831.davem@davemloft.net>
References: <1317357897.3274.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756719Ab1JCSBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:01:34 -0400
In-Reply-To: <1317357897.3274.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Sep 2011 06:44:57 +0200

> Allows ss command (iproute2) to display "ecnseen" if at least one packet
> with ECT(0) or ECT(1) or ECN was received by this socket.
> 
> "ecn" means ECN was negociated at session establishment (TCP level)
> 
> "ecnseen" means we received at least one packet with ECT fields set (IP
> level)
> 
> ss -i
> ...
> ESTAB      0      0   192.168.20.110:22  192.168.20.144:38016
> ino:5950 sk:f178e400
> 	 mem:(r0,w0,f0,t0) ts sack ecn ecnseen bic wscale:7,8 rto:210
> rtt:12.5/7.5 cwnd:10 send 9.3Mbps rcv_space:14480
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
