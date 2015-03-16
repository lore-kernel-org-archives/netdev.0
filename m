From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2 net-next] rhashtable: Avoid calculating hash again to
 unlock
Date: Tue, 17 Mar 2015 07:48:36 +1100
Message-ID: <20150316204836.GA6534@gondor.apana.org.au>
References: <cover.1426494808.git.tgraf@suug.ch>
 <cover.1426494808.git.tgraf@suug.ch>
 <e66c2872d3182c2df12f5657903f19e8ffc1f0f0.1426494808.git.tgraf@suug.ch>
 <20150316.162202.2166849044626317059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41526 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933129AbbCPUsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:48:42 -0400
Content-Disposition: inline
In-Reply-To: <20150316.162202.2166849044626317059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 04:22:02PM -0400, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Mon, 16 Mar 2015 10:42:26 +0100
> 
> > Caching the lock pointer avoids having to hash on the object
> > again to unlock the bucket locks.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> I'd like to hold off on this.
> 
> My understanding is that Herbert plans to expand the table size
> synchonously during insert in emergency situations, and in that regime
> some of these optimization won't be valid.

Actually this patch does not conflict with my multiple rehashing
work (the final scheme I used only requires two locks) so please
feel free to merge it and I will rebase my stuff.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
