From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH 3/5] sched/preempt: cond_resched_softirq() must check
 for softirq
Date: Wed, 15 Jun 2016 16:00:47 +0200
Message-ID: <1465999247.13041.4.camel@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
	 <5e046ef45554b053d22e76809a8faf546c3c0720.1465996447.git.pabeni@redhat.com>
	 <20160615134817.GJ30909@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932290AbcFOOAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 10:00:51 -0400
In-Reply-To: <20160615134817.GJ30909@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-15 at 15:48 +0200, Peter Zijlstra wrote:
> On Wed, Jun 15, 2016 at 03:42:04PM +0200, Paolo Abeni wrote:
> > Currently cond_resched_softirq() fails to reschedule if there
> > are pending softirq but no other running process. This happens
> > i.e. when receiving an interrupt with local bh disabled.
> > 
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> All your patches appear to have this broken SoB chain.
> 
> As presented it suggests you wrote the patches, which matches with From,
> however it then suggests Hannes collected and send them onwards, not so
> much.
> 
> Please correct.

My bad. I'll re-submit. The intention was to specify this is joint work
done together with Hannes.

Paolo
