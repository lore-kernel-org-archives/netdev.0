From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Sun, 17 May 2015 09:38:29 +0800
Message-ID: <20150517013829.GB5161@gondor.apana.org.au>
References: <20150515030623.GA14994@gondor.apana.org.au>
 <20150514.234615.235930228362522399.davem@davemloft.net>
 <20150515063057.GA16440@gondor.apana.org.au>
 <20150516.180946.2182730749654333791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60411 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbEQBik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 21:38:40 -0400
Content-Disposition: inline
In-Reply-To: <20150516.180946.2182730749654333791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2015 at 06:09:46PM -0400, David Miller wrote:
>
> Obviously something like 50 or 100 is too much.
> 
> Perhaps something between 5 and 10.

You are even more parsimonious than I :) Because the maximum chain
length grows at a rate of logN * loglogN, I had chosen the number
16 which should be sufficient even if you had a 2^32 table (which
you currently can't as we max out somewhere below that).

FWIW Thomas did some numbers on this and apparent 10 gets breached
in a 2^24 table at 100% utilisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
