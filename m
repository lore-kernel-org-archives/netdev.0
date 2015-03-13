From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/6] rhashtable: Free bucket tables asynchronously after
 rehash
Date: Fri, 13 Mar 2015 15:42:12 +0000
Message-ID: <20150313154212.GF17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLB-0000Bx-Lm@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57612 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbCMPmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 11:42:13 -0400
Content-Disposition: inline
In-Reply-To: <E1YWMLB-0000Bx-Lm@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> There is in fact no need to wait for an RCU grace period in the
> rehash function, since all insertions are guaranteed to go into
> the new table through spin locks.
> 
> This patch uses call_rcu to free the old/rehashed table at our
> leisure.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
