From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Mon, 17 Nov 2014 06:20:00 +0000
Message-ID: <20141117062000.GB8723@casper.infradead.org>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
 <20141115032512.GA19299@gondor.apana.org.au>
 <20141115111626.GP19157@casper.infradead.org>
 <20141115112313.GA20970@gondor.apana.org.au>
 <20141115155108.GA21998@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52993 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbaKQGUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 01:20:03 -0500
Content-Disposition: inline
In-Reply-To: <20141115155108.GA21998@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/14 at 11:51pm, Herbert Xu wrote:
> So I noticed that you got rid of the rehash when you converted
> netlink over to rthashtable.  Was this aspect of the conversion
> discussed anywhere? In particular, how do you protect against
> a malicious user that's trying to attack the netlink hash table?

I looked at the trade off between lockless lookups and rehashing and
figured it makes sense to chose making lookups cheaper as sockets can
be constrained per user. However, given the followup-up discussion it
seems we can get both.

Thomas
