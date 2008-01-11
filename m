From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 21:38:52 +1100
Message-ID: <20080111103852.GB26740@gondor.apana.org.au>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local> <20080111091140.GB2183@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1259 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754040AbYAKKuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 05:50:15 -0500
Content-Disposition: inline
In-Reply-To: <20080111091140.GB2183@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 10:11:40AM +0100, Jarek Poplawski wrote:
> 
> So, IOW: strictly speaking you are right, r can't change here, but I
> meant r vs. the returned value! Before the patch the returned value
> couldn't be NULL unless all elements of the list were looped. After
> this patch it seems possible...

Since rcu_derference(r) is always the same as r this patch cannot
change the value returned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
