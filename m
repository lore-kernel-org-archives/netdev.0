From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 14:42:50 +0100
Message-ID: <17901.28634.359369.341093@robur.slu.se>
References: <20070305.202632.74752497.davem@davemloft.net>
	<45ED14E6.7090109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:48109 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934119AbXCFNnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 08:43:23 -0500
In-Reply-To: <45ED14E6.7090109@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > Well, maybe... but after looking robert's trash, I discovered its model is 
 > essentially a big (2^18 slots) root node (our hash table), and very few 
 > order:1,2,3 nodes.
 
 It's getting "hashlike" yes. I guess all effective algorithms today is doing
 some sort of "index" lookup and for large number of entries we cannot expect 
 to find the next node in the same cache line so the "tree depth" becomes a
 crucial performance factor. IMO nothing can beat a prefect distributed and 
 perfect sized hash. The trash work is an effort to get close with dynamic 
 data structure.

 Cheers
						--ro
