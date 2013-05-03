From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Fri, 03 May 2013 14:58:57 -0700
Message-ID: <1367618337.22983.0.camel@edumazet-glaptop>
References: <1366786204.5977.10.camel@marge.simpson.net>
	 <1366853695.8964.120.camel@edumazet-glaptop>
	 <1366865490.4595.22.camel@marge.simpson.net>
	 <1366866233.8964.128.camel@edumazet-glaptop>
	 <20130426105030.GE20927@linutronix.de>
	 <1367455779.30667.113.camel@gandalf.local.home>
	 <20130503082058.GA8230@linutronix.de>
	 <1367589787.29805.23.camel@edumazet-glaptop>
	 <1367594003.7373.13.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1367594003.7373.13.camel@gandalf.local.home>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-03 at 11:13 -0400, Steven Rostedt wrote:
> On Fri, 2013-05-03 at 07:03 -0700, Eric Dumazet wrote:
> > On Fri, 2013-05-03 at 10:20 +0200, Sebastian Andrzej Siewior wrote:
> > > * Steven Rostedt | 2013-05-01 20:49:39 [-0400]:
> > > 
> > > >Is this something going into the stable tree, or does it not affect 3.0,
> > > >3.2, 3.4 or 3.6?
> > > 
> > > Mike Galbraith reported it against v3.6 so I would say that this is one
> > > candidate. I just booted v3.4.41-rt55 and it runs for 20 minutes now
> > > without any issues. Maybe it crashes after I sent the email but I hope
> > > it does not :)
> > 
> > Thats because the particular way to trigger the bug was to use the IP
> > early demux, and it was added in 3.5
> 
> Is it OK to keep it? I pulled the patch into 3.2-rt and 3.4-rt. I can
> remove it if you think it's not necessary and will cause a slight
> performance penalty.

You can keep it.

I was refereeing to the method used to trigger the bug.

But the bug is really old and could trigger with other workloads.



