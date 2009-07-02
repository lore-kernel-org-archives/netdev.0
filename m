From: Robert Olsson <robert@herjulf.net>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Thu, 2 Jul 2009 17:31:58 +0200
Message-ID: <19020.53998.330803.83554@gargle.gargle.HOWL>
References: <20090630204141.GB3026@ami.dom.local>
	<4A4AA03D.5090808@itcare.pl>
	<20090701063651.GA4876@ff.dom.local>
	<20090701072409.GA12592@ff.dom.local>
	<4A4B2FA8.3040007@itcare.pl>
	<20090701101333.GB12715@ff.dom.local>
	<20090701110407.GC12715@ff.dom.local>
	<4A4BE06F.3090608@itcare.pl>
	<20090702053216.GA4954@ff.dom.local>
	<4A4C48FD.7040002@itcare.pl>
	<20090702060011.GB4954@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av6-2-sn3.vrr.skanova.net ([81.228.9.180]:52503 "EHLO
	av6-2-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbZGBQBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:01:04 -0400
In-Reply-To: <20090702060011.GB4954@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:

 > Yes, it looks like we can't free memory so simple because of such huge
 > latencies.  

 Controlling RCU seems crucial. Insertion of the full BGP table increased
 from 2 seconds to > 20 min with one synchronize_rcu patches.

 And fib_trie "worst case" wrt memory is the root node. So maybe we should 
 monitor changes in root node and use this to control synchronize_rcu.

 Didn't Paul suggest something like this?

 And with don't find any decent solution we have to add an option for 
 a fixed and pre-allocated root-nod typically for BGP-routers.

 Cheers
					--ro
