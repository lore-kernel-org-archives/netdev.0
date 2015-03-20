From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/7] rhashtable: Make rhashtable_init params argument
 const
Date: Fri, 20 Mar 2015 13:16:28 +0000
Message-ID: <20150320131628.GA26470@casper.infradead.org>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <E1YYubr-0004km-9d@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39533 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbCTNQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 09:16:29 -0400
Content-Disposition: inline
In-Reply-To: <E1YYubr-0004km-9d@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/15 at 09:56pm, Herbert Xu wrote:
> This patch marks the rhashtable_init params argument const as
> there is no reason to modify it since we will always make a copy
> of it in the rhashtable.
> 
> This patch also fixes a bug where we don't actually round up the
> value of min_size unless it is less than HASH_MIN_SIZE.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for fixing this up

Acked-by: Thomas Graf <tgraf@suug.ch>
