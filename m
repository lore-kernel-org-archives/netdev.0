From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from
 netlink_insert
Date: Fri, 18 Sep 2015 10:09:22 +0800
Message-ID: <20150918020922.GA30070@gondor.apana.org.au>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
 <20150810.110015.1616067694505641781.davem@davemloft.net>
 <20150917054114.GN1983@Chimay.local>
 <CA+55aFxyqfxJphqDF_X4hG40b21XWP0fFdMhFJKn6riy5-kmtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Paasch <christoph.paasch@gmail.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60925 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbIRCJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 22:09:40 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFxyqfxJphqDF_X4hG40b21XWP0fFdMhFJKn6riy5-kmtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 11:47:12AM -0700, Linus Torvalds wrote:
> On Wed, Sep 16, 2015 at 10:41 PM, Christoph Paasch
> <christoph.paasch@gmail.com> wrote:
> >
> > can this patch get queued up for 4.1 as well?
> > It seems to fix a similar issue in 4.1.6.
> 
> I think Herbert has an additional patch for this issue. But yes, I
> think should be scheduled for stable. Herbert?

Yes this should be safe for stable, even though the real cause of
the problem is probably the one that Tejun spotted.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
