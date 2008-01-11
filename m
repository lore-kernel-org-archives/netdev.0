From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 12:30:54 +0100
Message-ID: <20080111113054.GB2708@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local> <20080111091140.GB2183@ff.dom.local> <20080111103852.GB26740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:61948 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757821AbYAKLYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 06:24:44 -0500
Received: by fk-out-0910.google.com with SMTP id z23so766832fkz.5
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 03:24:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080111103852.GB26740@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 09:38:52PM +1100, Herbert Xu wrote:
> On Fri, Jan 11, 2008 at 10:11:40AM +0100, Jarek Poplawski wrote:
> > 
> > So, IOW: strictly speaking you are right, r can't change here, but I
> > meant r vs. the returned value! Before the patch the returned value
> > couldn't be NULL unless all elements of the list were looped. After
> > this patch it seems possible...
> 
> Since rcu_derference(r) is always the same as r this patch cannot
> change the value returned.

Right!!! (But, you mean: "always the same as r" for local r, I hope...)

So, my moronness's selfdocumenting features are not overrated at all!

Thanks again,
Jarek P.
