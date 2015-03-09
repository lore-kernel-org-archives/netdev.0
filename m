From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Mon, 9 Mar 2015 15:32:07 -0700
Message-ID: <20150309223207.GB18010@jtriplet-mobl1>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
 <20150309222631.GA12221@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:58190 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbCIWcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:32:17 -0400
Content-Disposition: inline
In-Reply-To: <20150309222631.GA12221@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 09:26:31AM +1100, Herbert Xu wrote:
> Hi Dave:
> 
> These two patches implement arbitrary rehashing in rhashtable.  The
> idea is based on the hashtable in net/bridge/br_multicast.c plus
> the suggestion by Josh Triplett to avoid using two linked lists.

Awesome.

> I have tested it using netlink but obviously more testing especially
> using netfilter would be welcome.
> 
> After this I would like to explore the idea of allowing multiple
> rehashes in parallel.  This would allow us to not have to rehash
> synchronously when the table gets too big and the previous rehash
> hasn't finished.

Aieee.

- Josh Triplett
