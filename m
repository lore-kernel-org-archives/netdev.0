From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Fri, 10 Jul 2009 16:02:47 +0800
Message-ID: <20090710080247.GA2693@gondor.apana.org.au>
References: <20090608023757.GA6244@localhost> <20090706105216.GA19124@gondor.apana.org.au> <20090709131746.GA27965@localhost> <20090709.171355.09466097.davem@davemloft.net> <20090710080017.GA24168@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49913 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751023AbZGJICx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 04:02:53 -0400
Content-Disposition: inline
In-Reply-To: <20090710080017.GA24168@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2009 at 04:00:17PM +0800, Wu Fengguang wrote:
> 
> The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
> the networking code shall do it anyway, because sk_allocation defaults
> to GFP_KERNEL. It seems that currently the networking code simply uses
> a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?

Yep because they're done from softirq context.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
