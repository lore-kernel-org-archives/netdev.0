From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 08:23:30 +1000
Message-ID: <20080821222330.GE14521@gondor.apana.org.au>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124834.GA8794@gondor.apana.org.au> <20080821125501.GF4079@ff.dom.local> <20080821131218.GA9208@gondor.apana.org.au> <20080821185857.GA2665@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54988 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753911AbYHUWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:23:36 -0400
Content-Disposition: inline
In-Reply-To: <20080821185857.GA2665@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
>
> root qdisc with pointers copied to every dev_queue. At least I can't
> see nothing more in qdisc_create() and qdisc_graft(). So,
> qdisc_lookup() seems to be designed for the future (or to do this
> lookup more exactly with additional loops...). 

We've got at least the RX and TX queues.  That makes two locks and
two lists.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
