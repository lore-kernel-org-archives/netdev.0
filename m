From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 08:49:31 +0000
Message-ID: <20080822084931.GB2645@ff.dom.local>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124834.GA8794@gondor.apana.org.au> <20080821125501.GF4079@ff.dom.local> <20080821131218.GA9208@gondor.apana.org.au> <20080821185857.GA2665@ami.dom.local> <20080821222330.GE14521@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:56182 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbYHVIth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 04:49:37 -0400
Received: by nf-out-0910.google.com with SMTP id d3so166883nfc.21
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 01:49:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821222330.GE14521@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 08:23:30AM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
> >
> > root qdisc with pointers copied to every dev_queue. At least I can't
> > see nothing more in qdisc_create() and qdisc_graft(). So,
> > qdisc_lookup() seems to be designed for the future (or to do this
> > lookup more exactly with additional loops...). 
> 
> We've got at least the RX and TX queues.  That makes two locks and
> two lists.

RX currently doesn't add anything to the list.

Jarek P.
