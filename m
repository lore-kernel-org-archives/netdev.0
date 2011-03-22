From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 10:56:38 +0100
Message-ID: <20110322095638.GA26130@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
 <1300730838.2884.578.camel@edumazet-laptop>
 <1300738540.2837.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:35361 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753772Ab1CVJ5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 05:57:09 -0400
Content-Disposition: inline
In-Reply-To: <1300738540.2837.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH] ipvs: fix a typo in __ip_vs_control_init()

This fix and Simon's:

  IPVS: Use global mutex in ip_vs_app.c

Did the trick here, the IPVS related SLAB corruptions are now gone.

Thanks guys!

	Ingo
