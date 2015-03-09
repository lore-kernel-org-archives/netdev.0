From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Tue, 10 Mar 2015 09:26:31 +1100
Message-ID: <20150309222631.GA12221@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50009 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbCIW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:26:40 -0400
Content-Disposition: inline
In-Reply-To: <20150309095833.GA4028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

These two patches implement arbitrary rehashing in rhashtable.  The
idea is based on the hashtable in net/bridge/br_multicast.c plus
the suggestion by Josh Triplett to avoid using two linked lists.

I have tested it using netlink but obviously more testing especially
using netfilter would be welcome.

After this I would like to explore the idea of allowing multiple
rehashes in parallel.  This would allow us to not have to rehash
synchronously when the table gets too big and the previous rehash
hasn't finished.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
