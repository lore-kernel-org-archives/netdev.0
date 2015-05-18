From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Tue, 19 May 2015 06:35:26 +0800
Message-ID: <20150518223526.GA25597@gondor.apana.org.au>
References: <20150515063057.GA16440@gondor.apana.org.au>
 <20150516.180946.2182730749654333791.davem@davemloft.net>
 <20150517013829.GB5161@gondor.apana.org.au>
 <20150518.161201.1959117179761854761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56700 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbbERWfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 18:35:37 -0400
Content-Disposition: inline
In-Reply-To: <20150518.161201.1959117179761854761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 04:12:01PM -0400, David Miller wrote:
>
> Ok, this of course depends upon the distribution of the input data
> and the strength/suitability of the hash function.
> 
> I'm a little bit disappointed in what Thomas found.  I would expect
> the distribution to be at least a little bit better.

Just to make it clear this is not a problem with uneven distribution.
The same thing would happen with any hash function.  It's essentially
a generalised birthday paradox.

Of course the average chain length is still what you expect it to
be, it's only the maximum chain length that grows at logN loglogN.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
