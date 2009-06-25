From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Thu, 25 Jun 2009 10:54:02 -0700
Message-ID: <20090625175402.GB8852@linux.vnet.ibm.com>
References: <20090624164535.GA13334@linux.vnet.ibm.com> <20090624180303.GE7576@elte.hu> <20090624184423.GK6779@linux.vnet.ibm.com> <20090625095953.GC29980@elte.hu> <alpine.LFD.2.01.0906250944511.3605@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:43429 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbZFYRyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 13:54:02 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906250944511.3605@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2009 at 09:47:02AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 25 Jun 2009, Ingo Molnar wrote:
> > 
> > Our general preference is to zap code.
> > 
> > /me stares at:
> > 
> >   $ git diff --stat -M v2.6.30..v2.6.31-rc1 | tail -1
> >   7743 files changed, 782278 insertions(+), 403162 deletions(-)
> > 
> > /me corrects himself:
> 
> Yes. Our general preference is to zap code, if only because it's so damn 
> unusual.
> 
> When one out of a hundred patches actually has more removals than 
> additions, we make a big deal out of it ("Look - I actually simplified 
> things"). For the 99 other patches we never size in polite company.
> 
> Oh well. But every time we add lines, we do it with the _best_ intentions.

Indeed, I must confess that my recent patch removing about 1,000 lines
of code is not all that typical of my submissions...

							Thanx, Paul
