From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 18:05:55 +0100
Message-ID: <17901.40819.204568.650642@robur.slu.se>
References: <20070305.202632.74752497.davem@davemloft.net>
	<45ED14E6.7090109@cosmosbay.com>
	<17901.28634.359369.341093@robur.slu.se>
	<200703061518.09309.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:52505 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965956AbXCFRG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 12:06:29 -0500
In-Reply-To: <200703061518.09309.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > Indeed. It would be nice to see how it performs with say 2^20 elements...
 > Because with your data, I wonder if the extra complexity of the trash is worth 
 > it (since most lookups are going to only hit the hash and give the answer 
 > without intermediate nodes)

 I don't know if I understand you fully. Yes in most cases the first lookup via
 "hash-header" will take us to direct to the correct leaf. If there are "collisions" 
 we have to sort them out by adding intermediate nodes.

 Something like where you have resizable hash where is each bucket in turn is a 
 resizable hash etc.

 Cheers
						--ro
