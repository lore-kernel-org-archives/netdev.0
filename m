From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 19:55:43 +0100
Message-ID: <17901.47407.88896.134338@robur.slu.se>
References: <20070305.202632.74752497.davem@davemloft.net>
	<200703061518.09309.dada1@cosmosbay.com>
	<17901.40819.204568.650642@robur.slu.se>
	<200703061820.45986.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:53728 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965509AbXCFS4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:56:19 -0500
In-Reply-To: <200703061820.45986.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > With 2^20 entries, your actual limit of 2^19 entries in root node will 
 > probably show us quite different numbers for order-1,2,3,4... tnodes

 Yeep trie will get deeper and lookup more costly as insert and delete.
 The 2^19 was that was getting memory alloction problem that I never
 sorted out.

 > Yes, numbers you gave us basically showed a big root node, and mainly leaves 
 > and very few tnodes.
 > 
 > I was interested to see the distribution in case the root-node limit is hit, 
 > and we load into the table a *lot* of entries.

 Maxlength etc... well maybe root-restriction should be removed and just have 
 maxsize instead.

 Cheers
						--ro
