From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 21:37:42 +1100
Message-ID: <20080111103742.GA26740@gondor.apana.org.au>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1278 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754322AbYAKK4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 05:56:22 -0500
Content-Disposition: inline
In-Reply-To: <20080111083010.GA2183@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 09:30:10AM +0100, Jarek Poplawski wrote:
> 
> It looks like I'm really too lazy and/or these selfdocumenting features
> of RCU are a bit overrated: one can never be sure which pointer is
> really RCU protected without checking a few places?! So, after looking
> at this rt_cache_get_next() and this patch only, it's looks like the
> third candidate after seq->private and rtable...

Perhaps we could introduce a sparse attribute for it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
