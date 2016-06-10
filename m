From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 12:45:25 -0400
Message-ID: <20160610124525.32cac2e0@gandalf.local.home>
References: <20160526195641.6c26e979@gandalf.local.home>
	<20160602161235.GA12971@linutronix.de>
	<20160604071131.08d449db@grimm.local.home>
	<20160610155717.GB10775@linutronix.de>
	<20160610121118.03f281e8@gandalf.local.home>
	<8582eb37-3b5b-ee7e-3a67-8f4609b0ac3f@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alison@peloton-tech.com, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8582eb37-3b5b-ee7e-3a67-8f4609b0ac3f@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Jun 2016 18:20:22 +0200
Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> > We actually triggered a starvation due to this. I was just seeing if
> > Alison hit the same issue we did in our tests.  
> 
> Okay. Didn't get this information from him. But this is only because
> the softirqs not running in ksoftirqd, right?

Right, I think we supplied this patch before we added the one that
would push repeated softirqs to ksoftirqd. We probably should see if
that patch alone fixes our issue.

-- Steve
