From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: add SNMP counters tracking incoming
 ECN bits
Date: Thu, 08 Aug 2013 22:25:19 -0700 (PDT)
Message-ID: <20130808.222519.1955301555484469421.davem@davemloft.net>
References: <1375370791.10515.154.camel@edumazet-glaptop>
	<1375785131.4457.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676Ab3HIFZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 01:25:22 -0400
In-Reply-To: <1375785131.4457.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Aug 2013 03:32:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With GRO/LRO processing, there is a problem because Ip[6]InReceives SNMP
> counters do not count the number of frames, but number of aggregated
> segments.
> 
> Its probably too late to change this now.
> 
> This patch adds four new counters, tracking number of frames, regardless
> of LRO/GRO, and on a per ECN status basis, for IPv4 and IPv6.
> 
> Ip[6]NoECTPkts : Number of packets received with NOECT
> Ip[6]ECT1Pkts  : Number of packets received with ECT(1)
> Ip[6]ECT0Pkts  : Number of packets received with ECT(0)
> Ip[6]CEPkts    : Number of packets received with Congestion Experienced
> 
> lph37:~# nstat | egrep "Pkts|InReceive"
> IpInReceives                    1634137            0.0
> Ip6InReceives                   3714107            0.0
> Ip6InNoECTPkts                  19205              0.0
> Ip6InECT0Pkts                   52651828           0.0
> IpExtInNoECTPkts                33630              0.0
> IpExtInECT0Pkts                 15581379           0.0
> IpExtInCEPkts                   6                  0.0
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
