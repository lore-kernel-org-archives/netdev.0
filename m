From: Andi Kleen <andi@firstfloor.org>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:15:22 +0200
Message-ID: <20100416071522.GY18855@one.firstfloor.org>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com> <1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi> <20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi> <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com> <1271395106.16881.3645.camel@edumazet-laptop> <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, hadi@cyberus.ca,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48531 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866Ab0DPHPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 03:15:23 -0400
Content-Disposition: inline
In-Reply-To: <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Come on Changli.
> >
> > How do you wake up a thread on a remote cpu ?
> >
> 
> resched IPI, apparently. But it is async absolutely. and its IRQ
> handler is lighter.

It shouldn't be a lot lighter than the new fancy "queued smp_call_function"
that's in the tree for a few releases. So it would surprise me if it made
much difference. In the old days when there was only a single lock for
s_c_f() perhaps...

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
