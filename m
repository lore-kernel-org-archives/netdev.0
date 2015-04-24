From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 16:22:11 +0800
Message-ID: <20150424082211.GA29731@gondor.apana.org.au>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <20150424080608.GM21799@casper.infradead.org>
 <20150424081224.GA29599@gondor.apana.org.au>
 <20150424081539.GN21799@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org, kaber@trash.net, johannes.berg@intel.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42912 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965702AbbDXIWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:22:21 -0400
Content-Disposition: inline
In-Reply-To: <20150424081539.GN21799@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 09:15:39AM +0100, Thomas Graf wrote:
> 
> You are claiming that the rhashtable convertion removed a cap. I'm
> not seeing such a change. Can you point me to where netlink_insert()
> enforced a cap pre-rhashtable?

OK you are right.  We never had such a limit.  In that case I'm
OK with Johannes's original patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
