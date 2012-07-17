From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Tue, 17 Jul 2012 07:41:01 -0700 (PDT)
Message-ID: <20120717.074101.134339589368651253.davem@davemloft.net>
References: <1342525290.2626.459.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkiran@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab2GQOlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:41:02 -0400
In-Reply-To: <1342525290.2626.459.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jul 2012 13:41:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Implement the RFC 5691 mitigation against Blind
> Reset attack using SYN bit.
> 
> Section 4.2 of RFC 5961 advises to send a Challenge ACK and drop
> incoming packet, instead of resetting the session.
> 
> Add a new SNMP counter to count number of challenge acks sent
> in response to SYN packets.
> (netstat -s | grep TCPSYNChallenge)
> 
> Remove obsolete TCPAbortOnSyn, since we no longer abort a TCP session
> because of a SYN flag.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
