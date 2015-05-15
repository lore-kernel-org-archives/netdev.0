From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 15 May 2015 11:06:23 +0800
Message-ID: <20150515030623.GA14994@gondor.apana.org.au>
References: <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <20150513080640.GA27800@gondor.apana.org.au>
 <20150514.222217.1991822787577994078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:51461 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423143AbbEODGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 23:06:34 -0400
Content-Disposition: inline
In-Reply-To: <20150514.222217.1991822787577994078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 10:22:17PM -0400, David Miller wrote:
>
> In my opinion, up to at least 2 X max_size, it's safe to allow the
> insert.  Assuming a well choosen hash function and a roughly even
> distribution.

OK I can make it 2 x max_size/table size.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
