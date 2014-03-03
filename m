From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: snmp stats for Fast Open, SYN rtx, and
 data pkts
Date: Mon, 03 Mar 2014 15:27:08 -0500 (EST)
Message-ID: <20140303.152708.479281530254240667.davem@davemloft.net>
References: <1393627642-19302-1-git-send-email-ycheng@google.com>
	<1393632473.26794.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, netdev@vger.kernel.org, edumazet@google.com,
	nanditad@google.com, brakmo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbaCCU1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:27:11 -0500
In-Reply-To: <1393632473.26794.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Feb 2014 16:07:53 -0800

> On Fri, 2014-02-28 at 14:47 -0800, Yuchung Cheng wrote:
>> Add the following snmp stats:
>> 
>> TCPFastOpenActiveFail: Fast Open attempts (SYN/data) failed beacuse
>> the remote does not accept it or the attempts timed out.
>> 
>> TCPSynRetrans: number of SYN and SYN/ACK retransmits to break down
>> retransmissions into SYN, fast-retransmits, timeout retransmits, etc.
>> 
>> TCPOrigDataSent: number of outgoing packets with original data (excluding
>> retransmission but including data-in-SYN). This counter is different from
>> TcpOutSegs because TcpOutSegs also tracks pure ACKs. TCPOrigDataSent is
>> more useful to track the TCP retransmission rate.
>> 
>> Change TCPFastOpenActive to track only successful Fast Opens to be symmetric to
>> TCPFastOpenPassive.
>> 
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Nandits Dukkipati <nanditad@google.com>
> 
> s/Nandits/Nandita/
> 
>> Signed-off-by: Larry Brakmo <brakmo@google.com>

s/Larry/Lawrence/

Yuchung can you correct your co-worker's names and resubmit?

Thanks!
