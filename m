From: Robert Olsson <robert@robur.slu.se>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 11:19:07 +0200
Message-ID: <19012.37515.146191.198843@robur.slu.se>
References: <4A43E9F1.90209@cosmosbay.com>
	<20090626080302.GB5204@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:46104 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365AbZFZJTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 05:19:05 -0400
In-Reply-To: <20090626080302.GB5204@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:

 > >> oprofile: using NMI interrupt.
 > >> Fix inflate_threshold_root. Now=15 size=11 bits
 > >> Fix inflate_threshold_root. Now=15 size=11 bits
 > >> Fix inflate_threshold_root. Now=15 size=11 bits
 > >> Fix inflate_threshold_root. Now=15 size=11 bits
 > >> Fix inflate_threshold_root. Now=15 size=11 bits
 > >> Fix inflate_threshold_root. Now=15 size=11 bits

 > On the other hand, even if there is no problem with memory, it seems
 > because of hitting max_resize the threshold should be changed, e.g.
 > by reverting the patch below.

 You seem to have some temporary memory problem. So the printout might be
 a bit misleading in this case. We really like to keep the root node as big 
 as we can to keep the tree as flat as possible for performance reasons.
 (We're even more motivated now when we can disable the route cache)

 So I'll guess the next insert/delete inflates the root node to be within
 the interval. So I'll assume this just a temporary failure?

 I would be nice to have *threshholds* settable by /proc or /sys. I would
 use this in the other direction to trade memory for even faster lookups. 
 
 But maybe experts memory allocation has some good suggestions.

 Cheers.
					--ro
 
