From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 09:15:39 +0100
Message-ID: <20150424081539.GN21799@casper.infradead.org>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <20150424080608.GM21799@casper.infradead.org>
 <20150424081224.GA29599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org, kaber@trash.net, johannes.berg@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44172 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbbDXIPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:15:40 -0400
Content-Disposition: inline
In-Reply-To: <20150424081224.GA29599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/15 at 04:12pm, Herbert Xu wrote:
> On Fri, Apr 24, 2015 at 09:06:08AM +0100, Thomas Graf wrote:
> >
> > Which users are you talking about? Both Netlink and TIPC still
> > have an upper limit. nft sets are controlled by privileged users.
> 
> There is no limit in netlink apart from UINT_MAX AFAICS.  Allowing
> UINT_MAX entries into a hash table limited to 64K is not a good
> thing.

OK, so you are saying that the Netlink limit is too low? Then let's
fix that.

You are claiming that the rhashtable convertion removed a cap. I'm
not seeing such a change. Can you point me to where netlink_insert()
enforced a cap pre-rhashtable?
