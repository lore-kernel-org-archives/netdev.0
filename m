From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v1 PATCH 7/7] rhashtable: Rip out obsolete out-of-line interface
Date: Fri, 20 Mar 2015 20:25:16 +0000
Message-ID: <20150320202516.GA27511@casper.infradead.org>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <E1YYuby-0004mT-AN@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41897 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbCTUZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:25:18 -0400
Content-Disposition: inline
In-Reply-To: <E1YYuby-0004mT-AN@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/15 at 09:57pm, Herbert Xu wrote:
> Now that all rhashtable users have been converted over to the
> inline interface, this patch removes the unused out-of-line
> interface.

Any reason to keep the _fast() suffix if we only keep the inline
variants anyway?
