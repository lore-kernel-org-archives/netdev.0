From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/5] sched/preempt: cond_resched_softirq() must check for
 softirq
Date: Wed, 15 Jun 2016 15:48:17 +0200
Message-ID: <20160615134817.GJ30909@twins.programming.kicks-ass.net>
References: <cover.1465996447.git.pabeni@redhat.com>
 <5e046ef45554b053d22e76809a8faf546c3c0720.1465996447.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37892 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbcFONs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 09:48:26 -0400
Content-Disposition: inline
In-Reply-To: <5e046ef45554b053d22e76809a8faf546c3c0720.1465996447.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 03:42:04PM +0200, Paolo Abeni wrote:
> Currently cond_resched_softirq() fails to reschedule if there
> are pending softirq but no other running process. This happens
> i.e. when receiving an interrupt with local bh disabled.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

All your patches appear to have this broken SoB chain.

As presented it suggests you wrote the patches, which matches with From,
however it then suggests Hannes collected and send them onwards, not so
much.

Please correct.
