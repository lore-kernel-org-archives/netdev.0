From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 23:14:00 +0200
Message-ID: <20080821211400.GC2665@ami.dom.local>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124834.GA8794@gondor.apana.org.au> <20080821125501.GF4079@ff.dom.local> <20080821131218.GA9208@gondor.apana.org.au> <20080821185857.GA2665@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.231]:41460 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbYHUVMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:12:37 -0400
Received: by qb-out-0506.google.com with SMTP id a16so210999qbd.17
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 14:12:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821185857.GA2665@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
...
> sch_tree_lock() should be
> enough for now because in the current implementation we have only one
> root qdisc with pointers copied to every dev_queue.

Of course, except the state before qdisc_create() and qdisc_graft()
with default qdiscs, but it doesn't seem to matter here.

Jarek P.
