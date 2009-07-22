From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: the maximal speed of pktgen with 1Gbps NIC
Date: Wed, 22 Jul 2009 17:12:32 +0200
Message-ID: <1248275552.4058.0.camel@localhost>
References: <Pine.LNX.4.64.0907221032290.2211@zuben.voltaire.com>
	 <60230E21F17E384C9BF0B9C98D9E3FDC04BDC92E@sgp-sg-mb02.sgp.agilent.com>
	 <Pine.LNX.4.64.0907221448570.18880@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jon_zhou@agilent.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmburns.debconf.org ([89.16.166.49]:45757 "EHLO
	cmburns.debconf.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbZGVPkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 11:40:08 -0400
In-Reply-To: <Pine.LNX.4.64.0907221448570.18880@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-22 at 14:56 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 22 Jul 2009, jon_zhou@agilent.com wrote:
> 
> > anyone knows the maximal speed of pktgen with 1Gbps NIC?
> 
> You are limited by the number of packets per second (pps) your machine can 
> generate.  This limitation is given by the CPU speed and the NIC used.
> 
> The maximum pps I have seen with pktgen at 1Gbit/s is 1200 kpps.
> 
> 1Gbit/s wire speed pps with 64 bytes packets is approx 1953 kpps.
> (1000*10^6/(64*8) = 1953125)
[...]

You need to take the inter-packet gap into consideration too.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
