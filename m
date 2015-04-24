From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 11:38:34 -0400 (EDT)
Message-ID: <20150424.113834.1600876021127291309.davem@davemloft.net>
References: <20150424081224.GA29599@gondor.apana.org.au>
	<20150424081539.GN21799@casper.infradead.org>
	<20150424082211.GA29731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johannes@sipsolutions.net, netdev@vger.kernel.org,
	kaber@trash.net, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965151AbbDXPig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:38:36 -0400
In-Reply-To: <20150424082211.GA29731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 24 Apr 2015 16:22:11 +0800

> On Fri, Apr 24, 2015 at 09:15:39AM +0100, Thomas Graf wrote:
>> 
>> You are claiming that the rhashtable convertion removed a cap. I'm
>> not seeing such a change. Can you point me to where netlink_insert()
>> enforced a cap pre-rhashtable?
> 
> OK you are right.  We never had such a limit.  In that case I'm
> OK with Johannes's original patch.

Ok I'm applying Johanne's patch then, thanks.
