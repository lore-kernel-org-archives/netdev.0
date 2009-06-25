From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Thu, 25 Jun 2009 11:59:53 +0200
Message-ID: <20090625095953.GC29980@elte.hu>
References: <20090624164535.GA13334@linux.vnet.ibm.com> <20090624180303.GE7576@elte.hu> <20090624184423.GK6779@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55419 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbZFYKAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 06:00:18 -0400
Content-Disposition: inline
In-Reply-To: <20090624184423.GK6779@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Wed, Jun 24, 2009 at 08:03:03PM +0200, Ingo Molnar wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > >  include/linux/rcuclassic.h    |   15 ++-
> > 
> > heh, we dont have this file anymore ... as of today, right? :)
> 
> Ah, I was assuming that expedited RCU would happen before removal 
> of Classic RCU.

Our general preference is to zap code.

/me stares at:

  $ git diff --stat -M v2.6.30..v2.6.31-rc1 | tail -1
  7743 files changed, 782278 insertions(+), 403162 deletions(-)

/me corrects himself:

Okay, so the zapping of code is the divine guiding principle we've 
been following for 15 years. Ending up with a kernel that is 11 
million lines of code is a small imperfection of mankind and is to 
be fixed.

	Ingo
