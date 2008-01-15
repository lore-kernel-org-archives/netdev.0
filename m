From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 18:59:50 +0100
Message-ID: <18316.62614.638753.831122@robur.slu.se>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
	<20080114185843.0981f0ff@deepthought>
	<20080114210716.4b09c84d@deepthought>
	<478C4EB7.6060807@cosmosbay.com>
	<478C4FBE.5040308@cosmosbay.com>
	<20080115081905.3b8b6f05@deepthought>
	<18316.58111.211387.271534@robur.slu.se>
	<20080115182544.98c18d08.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:56178 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbYAOSAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 13:00:20 -0500
In-Reply-To: <20080115182544.98c18d08.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > 
 > So you think that a leaf cannot have 2 infos, one 'embeded' and one in the list ?
 
 Hello,
 
 The model I thought of is to have either: 

 1) One leaf_info embedded in leaf. A fast-path leaf. FP-leaf
 Or 
 2) The intct old leaf_info list with arbitrary number leaf_infos

 If plen_iinfo is >=0  It's a FP-leaf
 
 Cheers.
					--ro

