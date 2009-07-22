From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: the maximal speed of pktgen with 1Gbps NIC
Date: Wed, 22 Jul 2009 10:25:20 -0700
Message-ID: <20090722102520.27a024ed@nehalam>
References: <Pine.LNX.4.64.0907221032290.2211@zuben.voltaire.com>
	<60230E21F17E384C9BF0B9C98D9E3FDC04BDC92E@sgp-sg-mb02.sgp.agilent.com>
	<Pine.LNX.4.64.0907221448570.18880@tyr.diku.dk>
	<1248275552.4058.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, jon_zhou@agilent.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53374 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052AbZGVRZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 13:25:25 -0400
In-Reply-To: <1248275552.4058.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2009 17:12:32 +0200
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2009-07-22 at 14:56 +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 22 Jul 2009, jon_zhou@agilent.com wrote:
> > 
> > > anyone knows the maximal speed of pktgen with 1Gbps NIC?
> > 
> > You are limited by the number of packets per second (pps) your machine can 
> > generate.  This limitation is given by the CPU speed and the NIC used.
> > 
> > The maximum pps I have seen with pktgen at 1Gbit/s is 1200 kpps.
> > 
> > 1Gbit/s wire speed pps with 64 bytes packets is approx 1953 kpps.
> > (1000*10^6/(64*8) = 1953125)
> [...]
> 
> You need to take the inter-packet gap into consideration too.
> 
> Ben.

Speed	Packets/sec	TCP MByte/sec
 10 M	    14880.95	     1,170,351
100 M	   148809.52	    11,703,511
  1 G	  1488095.24	   123,755,256
 10 G	 14880952.38	 1,237,552,556
 40 G	 59523809.52	 4,950,210,224
100 G	148809523.81	12,375,525,559

* TCP assumes timestamp option and jumbo frames if possible.


http://www.erg.abdn.ac.uk/users/gorry/course/lan-pages/enet-calc.html
-- 
