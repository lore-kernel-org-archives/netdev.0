From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: add LINUX_MIB_IPRPFILTER snmp
 counter
Date: Thu, 03 Jun 2010 03:19:43 -0700 (PDT)
Message-ID: <20100603.031943.00479383.davem@davemloft.net>
References: <1275506732.2519.23.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021506560.32431@router.home>
	<1275516327.29413.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55456
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933425Ab0FCKTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:19:33 -0400
In-Reply-To: <1275516327.29413.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 00:05:27 +0200

> [PATCH net-next-2.6] ipv4: add LINUX_MIB_IPRPFILTER snmp counter
> 
> Christoph Lameter mentioned that packets could be dropped in input path
> because of rp_filter settings, without any SNMP counter being
> incremented. System administrator can have a hard time to track the
> problem.
> 
> This patch introduces a new counter, LINUX_MIB_IPRPFILTER, incremented
> each time we drop a packet because Reverse Path Filter triggers.
> 
> (We receive an IPv4 datagram on a given interface, and find the route to
> send an answer would use another interface)
> 
> netstat -s | grep IPReversePathFilter
>     IPReversePathFilter: 21714
> 
> Reported-by: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
