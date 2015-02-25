From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Ottawa and slow hash-table resize
Date: Wed, 25 Feb 2015 21:55:47 +1300
Message-ID: <20150225085547.GA2982@gondor.apana.org.au>
References: <20150223230619.GD15405@linux.vnet.ibm.com>
 <20150224083714.GB17306@casper.infradead.org>
 <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, tgraf@suug.ch, paulmck@linux.vnet.ibm.com,
	josh@joshtriplett.org, alexei.starovoitov@gmail.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44962 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbBYI4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 03:56:42 -0500
Content-Disposition: inline
In-Reply-To: <20150224.120944.866231994361475327.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 12:09:44PM -0500, David Miller wrote:
>
> So I think what I'm getting at is that we can allow parallel inserts
> but only up until the point where the resized tables thresholds are
> exceeded.

Agreed.  At some point you have to either resize immediately
or fail the insertion.

Note that once my rehash work is complete there is another option
of allowing multiple resizes.  That is, if we reach the limit
while a resize is still ongoing we simply start a new one
immediately.

I'm just coming back form vacation so please be patient and give
me a chance to finish this off.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
