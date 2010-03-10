From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 22:07:29 +0800
Message-ID: <20100310140729.GA25704@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com> <201003101041.32518.arnd@arndb.de> <1268217583.2880.2.camel@edumazet-laptop> <20100310104907.GA23752@gondor.apana.org.au> <20100310131317.GA6267@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932198Ab0CJOHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 09:07:42 -0500
Content-Disposition: inline
In-Reply-To: <20100310131317.GA6267@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 05:13:18AM -0800, Paul E. McKenney wrote:
>
> If CONFIG_PROVE_RCU is set, rcu_dereference() checks for rcu_read_lock()
> and rcu_dereference_bh() checks for either rcu_read_lock_bh() or BH
> being disabled.  Yes, this is a bit restrictive, but there are a few too
> many to check by hand these days.

Fair enough.  We should get those fixed then.  In fact I reckon
most of them should be using the BH variant so we might be able
to kill a few rcu_read_lock's which would be a real gain.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
