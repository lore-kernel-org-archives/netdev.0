From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Sat, 31 Jan 2015 12:15:47 +0000
Message-ID: <20150131121547.GA27437@casper.infradead.org>
References: <20150131093637.GA29106@gondor.apana.org.au>
 <20150131111652.GA22448@casper.infradead.org>
 <20150131112209.GA29869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41918 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbAaMPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 07:15:48 -0500
Content-Disposition: inline
In-Reply-To: <20150131112209.GA29869@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/15 at 10:22pm, Herbert Xu wrote:
> That's too late.  nft_hash will have freed all the elements
> before rhashtable_destroy gets called.

I see, so this is to accomodate nft_hash which doesn't remove
the elements from the hash but just frees them.

Acked-by: Thomas Graf <tgraf@suug.ch>
