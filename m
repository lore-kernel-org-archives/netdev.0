From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Mon, 14 Jan 2008 18:59:25 +0100
Message-ID: <18315.41725.417992.715140@robur.slu.se>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
	<20080112130824.54cc1fc3@deepthought>
	<18315.16984.456053.250600@robur.slu.se>
	<478B9D0B.5040301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:37991 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbYANSAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 13:00:06 -0500
In-Reply-To: <478B9D0B.5040301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > > Thats 231173/241649 = 96% with the current Internet routing.
 > >
 > > How about if would have a fastpath and store one entry direct in the 
 > > leaf struct this to avoid loading the leaf_info list in most cases?
 > >
 > > One could believe that both lookup and dump could improve.
 > >
 > You mean to include one "leaf_info" inside leaf structure, so that we 
 > can access it without cache line miss ?

 Yes.

 Cheers
					--ro
