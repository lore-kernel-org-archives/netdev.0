From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 16:12:24 +0800
Message-ID: <20150424081224.GA29599@gondor.apana.org.au>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <20150424080608.GM21799@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org, kaber@trash.net, johannes.berg@intel.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59627 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965370AbbDXIMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:12:35 -0400
Content-Disposition: inline
In-Reply-To: <20150424080608.GM21799@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 09:06:08AM +0100, Thomas Graf wrote:
>
> Which users are you talking about? Both Netlink and TIPC still
> have an upper limit. nft sets are controlled by privileged users.

There is no limit in netlink apart from UINT_MAX AFAICS.  Allowing
UINT_MAX entries into a hash table limited to 64K is not a good
thing.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
