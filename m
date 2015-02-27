From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Fri, 27 Feb 2015 17:30:11 -0500 (EST)
Message-ID: <20150227.173011.720468189098021308.davem@davemloft.net>
References: <54EDF4DD.1060709@iogearbox.net>
	<1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150226100235.GA16032@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
	David.Laight@ACULAB.COM, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbbB0WaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:30:14 -0500
In-Reply-To: <20150226100235.GA16032@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "tgraf@suug.ch" <tgraf@suug.ch>
Date: Thu, 26 Feb 2015 10:02:35 +0000

> I just want to point out here that TCP is not the only future
> use case. The station table for mac80211 has recently been
> converted. We need to keep all of them on the radar.

Just wanted to note in passing that I wonder how legal
net/core/neighbour.c:neigh_hash_grow() is.  It's growing an RCU
hashtable without using rhashtable. :-)
