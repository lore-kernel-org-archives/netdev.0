From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] net: net_rx_action fixes and clean-ups
Date: Sun, 21 Dec 2014 07:14:53 +1100
Message-ID: <20141220201453.GA6924@gondor.apana.org.au>
References: <20141220002327.GA31975@gondor.apana.org.au>
 <20141220003636.GA32187@gondor.apana.org.au>
 <1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141219.214000.819506179607476836.davem@davemloft.net>
 <20141220065529.GA2033@gondor.apana.org.au>
 <1419098412.11185.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60782 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaLTUPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:15:07 -0500
Content-Disposition: inline
In-Reply-To: <1419098412.11185.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 20, 2014 at 10:00:12AM -0800, Eric Dumazet wrote:
> 
> OK, but could you :
> 1) use pr_warn_once()
> 2) split the too long line
> 	pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
> 		     n->dev ? n->dev->name : "backlog");

Sure, I'll clean it up a bit too.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
