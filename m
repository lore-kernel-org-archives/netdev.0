From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 1/10] rhashtable: Add barrier to ensure we see new
 tables in walker
Date: Sun, 22 Mar 2015 10:47:43 +0000
Message-ID: <20150322104743.GB1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarW-0000uY-W0@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49943 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbbCVKrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 06:47:45 -0400
Content-Disposition: inline
In-Reply-To: <E1YZarW-0000uY-W0@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 07:03pm, Herbert Xu wrote:
> The walker is a lockless reader so it too needs an smp_rmb before
> reading the future_tbl field in order to see any new tables that
> may contain elements that we should have walked over.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
