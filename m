From: Robert Olsson <robert@herjulf.net>
Subject: Re: [PATCH] pktgen node allocation
Date: Mon, 22 Mar 2010 19:05:29 +0100
Message-ID: <19367.45417.306750.626323@gargle.gargle.HOWL>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	<1268990933.3048.15.camel@edumazet-laptop>
	<19363.32154.39665.185451@gargle.gargle.HOWL>
	<1269006465.3048.39.camel@edumazet-laptop>
	<19367.3346.643084.604021@gargle.gargle.HOWL>
	<1269243794.3029.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	olofh@kth.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av6-1-sn3.vrr.skanova.net ([81.228.9.179]:40756 "EHLO
	av6-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab0CVSWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:22:46 -0400
In-Reply-To: <1269243794.3029.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > > Result "manually" tuned. 
 > > 
 > > eth0 9617.7 M bit/s      822 k pps 
 > > eth1 9619.1 M bit/s      823 k pps 
 > > eth2 9619.1 M bit/s      823 k pps 
 > > eth3 9619.2 M bit/s      823 k pps 
 > > eth4 5995.2 M bit/s      512 k pps  <-  PCIe-x8
 > > eth5 5995.3 M bit/s      512 k pps  <-  PCIe-x8
 > > eth6 9619.2 M bit/s      823 k pps 
 > > eth7 9619.2 M bit/s      823 k pps 
 > > eth8 9619.1 M bit/s      823 k pps 
 > > eth9 9619.0 M bit/s      823 k pps 
 > > 
 > > > 90 Gbit/s

 DMA potential this box is about four 10g ports.

 > > Result "manually" mistuned by switching node 0 and 1. 
 > > 
 > > eth0 9613.6 M bit/s      822 k pps 
 > > eth1 9614.9 M bit/s      822 k pps 
 > > eth2 9615.0 M bit/s      822 k pps 
 > > eth3 9615.1 M bit/s      822 k pps 
 > > eth4 2918.5 M bit/s      249 k pps  <-  PCIe-x8
 > > eth5 2918.4 M bit/s      249 k pps  <-  PCIe-x8
 > > eth6 8597.0 M bit/s      735 k pps 
 > > eth7 8597.0 M bit/s      735 k pps 
 > > eth8 8568.3 M bit/s      733 k pps 
 > > eth9 8568.3 M bit/s      733 k pps 
 > > 
 > I wonder why eth0-eth3 results are unchanged after a node flip.

 Yes it's strange. 

 With clone_skb=1 we could see differences with just one GIGE interface 
 using 64 byte pkts so it might be very different on 10g.  We're getting 
 unfortunely closer to hardware...

 Cheers
					--ro

 
