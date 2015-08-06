From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from
 netlink_insert
Date: Fri, 7 Aug 2015 07:57:00 +0800
Message-ID: <20150806235700.GD22588@gondor.apana.org.au>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tgraf@suug.ch, torvalds@linux-foundation.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60633 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbHFX5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 19:57:20 -0400
Content-Disposition: inline
In-Reply-To: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2015 at 12:26:41AM +0200, Daniel Borkmann wrote:
>
> Reference: http://thread.gmane.org/gmane.linux.network/372676
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

But as I said earlier, this should not happen and if it does,
then our rhashtable is setup is broken.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
