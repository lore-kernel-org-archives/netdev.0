From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 13:31:32 +0100
Message-ID: <20080111123132.GC2708@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local> <20080111103742.GA26740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:3876 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757925AbYAKMZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 07:25:22 -0500
Received: by ug-out-1314.google.com with SMTP id z38so461934ugc.16
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 04:25:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080111103742.GA26740@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 09:37:42PM +1100, Herbert Xu wrote:
> On Fri, Jan 11, 2008 at 09:30:10AM +0100, Jarek Poplawski wrote:
> > 
> > It looks like I'm really too lazy and/or these selfdocumenting features
> > of RCU are a bit overrated: one can never be sure which pointer is
> > really RCU protected without checking a few places?! So, after looking
> > at this rt_cache_get_next() and this patch only, it's looks like the
> > third candidate after seq->private and rtable...
> 
> Perhaps we could introduce a sparse attribute for it?

I hope I won't be cursed by all those forced to additional writing,
so I'd only admit that after this patch there should be no problem
with identifying RCU protected data properly (maybe only this kind
of rcu_dereference() needs some popularization).

Jarek P.
