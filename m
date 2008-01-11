From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 10:23:51 +0100
Message-ID: <20080111092351.GA2639@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local> <20080111091140.GB2183@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:37373 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757002AbYAKJRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 04:17:41 -0500
Received: by ug-out-1314.google.com with SMTP id z38so439968ugc.16
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 01:17:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080111091140.GB2183@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 10:11:40AM +0100, Jarek Poplawski wrote:
...
> So, IOW: strictly speaking you are right, r can't change here, but I
> meant r vs. the returned value! Before the patch the returned value
> couldn't be NULL unless all elements of the list were looped. After

...even more strictly:

couldn't be NULL unless all buckets of the hash table were looped. After

> this patch it seems possible...

Jarek P.
