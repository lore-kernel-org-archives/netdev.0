From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFT] fib_trie: cleanup
Date: Thu, 26 Jul 2007 10:15:17 +0100
Message-ID: <20070726101517.01bfca6b@oldman.hamilton.local>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
	<20070726020431.1e693866.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39942 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752573AbXGZJPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:15:44 -0400
In-Reply-To: <20070726020431.1e693866.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jul 2007 02:04:31 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 26 Jul 2007 09:46:48 +0100 Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> > Try this out:
> >      * replace macro's with inlines
> >      * get rid of places doing multiple evaluations of NODE_PARENT
> 
> And it fixes the rcu abuse which resulted in
> http://lkml.org/lkml/2007/7/25/319.  Which I assume is what inspired the
> effort.
> 
> 
> your typecasting style is inconsistent:
> 
> > +	return rcu_dereference((struct tnode *) (node->parent & ~NODE_TYPE_MASK));
> 
> space

I have a couple of followon cleanup patches, one of them is whitespace demunging
