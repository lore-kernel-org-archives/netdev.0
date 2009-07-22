From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: the maximal speed of pktgen with 1Gbps NIC
Date: Wed, 22 Jul 2009 14:56:07 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907221448570.18880@tyr.diku.dk>
References: <Pine.LNX.4.64.0907221032290.2211@zuben.voltaire.com>
 <60230E21F17E384C9BF0B9C98D9E3FDC04BDC92E@sgp-sg-mb02.sgp.agilent.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: jon_zhou@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:57835 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbZGVM4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 08:56:41 -0400
In-Reply-To: <60230E21F17E384C9BF0B9C98D9E3FDC04BDC92E@sgp-sg-mb02.sgp.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 22 Jul 2009, jon_zhou@agilent.com wrote:

> anyone knows the maximal speed of pktgen with 1Gbps NIC?

You are limited by the number of packets per second (pps) your machine can 
generate.  This limitation is given by the CPU speed and the NIC used.

The maximum pps I have seen with pktgen at 1Gbit/s is 1200 kpps.

1Gbit/s wire speed pps with 64 bytes packets is approx 1953 kpps.
(1000*10^6/(64*8) = 1953125)

> on my pc, the maximal  speed is 500 Mbps when the packet size is 100 bytes(with boardcom 5755)

cat /proc/net/pktgen/ethXX to see how many pps pktgen is generating.

Quick calc tells me you a doing 625 kpps (500*10^6/(100*8) = 625000).


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
