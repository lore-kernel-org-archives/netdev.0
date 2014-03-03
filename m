From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: snmp stats for Fast Open, SYN rtx,
 and data pkts
Date: Mon, 03 Mar 2014 15:58:24 -0500 (EST)
Message-ID: <20140303.155824.2235118519552620477.davem@davemloft.net>
References: <1393878696-28137-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, nanditad@google.com,
	brakmo@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaCCU60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:58:26 -0500
In-Reply-To: <1393878696-28137-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  3 Mar 2014 12:31:36 -0800

> Add the following snmp stats:
> 
> TCPFastOpenActiveFail: Fast Open attempts (SYN/data) failed beacuse
> the remote does not accept it or the attempts timed out.
> 
> TCPSynRetrans: number of SYN and SYN/ACK retransmits to break down
> retransmissions into SYN, fast-retransmits, timeout retransmits, etc.
> 
> TCPOrigDataSent: number of outgoing packets with original data (excluding
> retransmission but including data-in-SYN). This counter is different from
> TcpOutSegs because TcpOutSegs also tracks pure ACKs. TCPOrigDataSent is
> more useful to track the TCP retransmission rate.
> 
> Change TCPFastOpenActive to track only successful Fast Opens to be symmetric to
> TCPFastOpenPassive.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> Signed-off-by: Lawrence Brakmo <brakmo@google.com>

Applied, thank you.
