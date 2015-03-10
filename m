From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Tue, 10 Mar 2015 18:20:11 +0000
Message-ID: <20150310182011.GC13155@casper.infradead.org>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
 <20150309222631.GA12221@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39691 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbbCJSUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:20:13 -0400
Content-Disposition: inline
In-Reply-To: <20150309222631.GA12221@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/15 at 09:26am, Herbert Xu wrote:
> After this I would like to explore the idea of allowing multiple
> rehashes in parallel.  This would allow us to not have to rehash
> synchronously when the table gets too big and the previous rehash
> hasn't finished.

Another interesting idea was to allow growing faster than 2x. It
actually became easier with this generic rehashing code because
the number of bucket locks can grow quicker than 2x again.
