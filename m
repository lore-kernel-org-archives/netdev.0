From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: implement RFC 5961 3.2
Date: Tue, 17 Jul 2012 01:36:34 -0700 (PDT)
Message-ID: <20120717.013634.138750003911972637.davem@davemloft.net>
References: <1342512785.2626.230.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkiran@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab2GQIge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 04:36:34 -0400
In-Reply-To: <1342512785.2626.230.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jul 2012 10:13:05 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Implement the RFC 5691 mitigation against Blind
> Reset attack using RST bit.
> 
> Idea is to validate incoming RST sequence,
> to match RCV.NXT value, instead of previouly accepted
> window : (RCV.NXT <= SEG.SEQ < RCV.NXT+RCV.WND)
> 
> If sequence is in window but not an exact match, send
> a "challenge ACK", so that the other part can resend an
> RST with the appropriate sequence.
> 
> Add a new sysctl, tcp_challenge_ack_limit, to limit
> number of challenge ACK sent per second.
> 
> Add a new SNMP counter to count number of challenge acks sent.
> (netstat -s | grep TCPChallengeACK)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
