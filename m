From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Thu, 21 May 2015 23:25:41 -0400 (EDT)
Message-ID: <20150521.232541.173137306546517818.davem@davemloft.net>
References: <20150512130855.GA29412@localhost.localdomain>
	<1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com, rapier@psc.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbbEVDZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:25:43 -0400
In-Reply-To: <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 May 2015 16:35:41 -0700

> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> 
> This patch tracks the total number of inbound and outbound segments on a
> TCP socket. One may use this number to have an idea on connection
> quality when compared against the retransmissions.
> 
> RFC4898 named these : tcpEStatsPerfSegsIn and tcpEStatsPerfSegsOut
> 
> These are a 32bit field each and can be fetched both from TCP_INFO
> getsockopt() if one has a handle on a TCP socket, or from inet_diag
> netlink facility (iproute2/ss patch will follow)
> 
> Note that tp->segs_out was placed near tp->snd_nxt for good data
> locality and minimal performance impact, while tp->segs_in was placed
> near tp->bytes_received for the same reason.
> 
> Join work with Eric Dumazet.
> 
> Note that received SYN are accounted on the listener, but sent SYNACK 
> are not accounted.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next, thanks.
