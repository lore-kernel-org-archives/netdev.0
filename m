From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] tcp: add generic netlink support for
 tcp_metrics
Date: Wed, 5 Sep 2012 00:00:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209042356460.2017@ja.ssi.bg>
References: <1346564178-1794-2-git-send-email-ja@ssi.bg> <1346633144.2563.97.camel@edumazet-glaptop> <alpine.LFD.2.00.1209031041340.1663@ja.ssi.bg> <20120904.154708.2099268692603008096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34413 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757726Ab2IDU5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 16:57:35 -0400
In-Reply-To: <20120904.154708.2099268692603008096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 4 Sep 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Mon, 3 Sep 2012 11:22:15 +0300 (EEST)
> 
> > 	BTW, is it appropriate to use kmem_cache for
> > metrics and as result call_rcu for freeing?
> 
> I think it would work as things are implemented currently in
> slab/slub/slob, however I would not rely upon it.
> 
> If you do move to a SLAB cache for the tcp metrics objects,
> you might consider SLAB_DESTROY_BY_RCU.  It's a very delicate
> facility (read the huge comment in linux/slab.h) but I think
> it provides the semantics we need for TCP metrics blobs.

	ok, I'll not mix it with the genl support
because I'm not prepared to do it soon...

> Looking forward to v3 :-)

	Sending...

Regards

--
Julian Anastasov <ja@ssi.bg>
