From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 6 Feb 2007 13:34:01 +0100
Message-ID: <20070206123401.GA8052@elte.hu>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net> <20070205.181026.122835715.davem@davemloft.net> <20070205181810.bbfbf42c.akpm@linux-foundation.org> <20070205.184408.34759062.davem@davemloft.net> <20070205185324.16b54b64.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, dipankar@in.ibm.com, paulmck@us.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56639 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbXBFMic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 07:38:32 -0500
Content-Disposition: inline
In-Reply-To: <20070205185324.16b54b64.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 05 Feb 2007 18:44:08 -0800 (PST) David Miller 
> <davem@davemloft.net> wrote:
> 
> > I bet this rcu_read_lock()-implies-preempt_disable() assumption has 
> > spread into other areas of the tree as well.
> 
> Me too.  Although one expects that other holes will cause might_sleep 
> or lockdep warnings pretty easily.
> 
> Still, life is hard enough as it is.  I think I'll shelve rcu-preempt 
> pending resolution of this.

that was pretty much the only place in the whole kernel that got hit by 
some rcu-preempt side-effect - and even this appears to show that it's a 
real bug that was in hiding. So please dont shelve RCU-preempt for this 
reason :-)

	Ingo
