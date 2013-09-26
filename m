From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] [RFC] net: Explicitly initialize u64_stats_sync
 structures for lockdep
Date: Thu, 26 Sep 2013 12:46:03 -0700
Message-ID: <1380224763.3165.208.camel@edumazet-glaptop>
References: <1380220464-28840-1-git-send-email-john.stultz@linaro.org>
		 <1380220464-28840-2-git-send-email-john.stultz@linaro.org>
	 <1380223585.3165.205.camel@edumazet-glaptop> <52448C46.2050107@linaro.org>
	 <52448D58.9060503@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:43647 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925Ab3IZTqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 15:46:06 -0400
In-Reply-To: <52448D58.9060503@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 12:39 -0700, John Stultz wrote:

> > No objection, though I worry that will obscure the lockdep key name,
> > causing all the u64_stat_sync locks to appear the same.
> >
> > I'll give it a quick shot to see if the compiler inlines it well enough
> > to preserve the name.
> Yea, unfortunately this causes the reports to all look like:
> 

> 
> So I suspect using the macro is the best approach here. Is that ok?

Oh well, right :)
