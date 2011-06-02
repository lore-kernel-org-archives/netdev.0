From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Thu, 02 Jun 2011 17:01:52 -0400
Message-ID: <1307048512.3667.28.camel@gandalf.stny.rr.com>
References: <4DE49D52.709@jp.fujitsu.com>
	 <1306854867.11899.31.camel@gandalf.stny.rr.com>
	 <20110602.135913.2065173997860104604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: sanagi.koki@jp.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, mingo@elte.hu,
	fweisbec@gmail.com, mathieu.desnoyers@efficios.com,
	tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110602.135913.2065173997860104604.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-06-02 at 13:59 -0700, David Miller wrote:
> From: Steven Rostedt <rostedt@goodmis.org>
> Date: Tue, 31 May 2011 11:14:27 -0400
> 
> > Note, the subject should not be "ftrace:", but "net:" or maybe even
> > "net/tracing", as this really has nothing to do with ftrace code. The
> > tracepoints are more generic than ftrace.
> 
> Do you guys mind if I take this in via the net-2.6 tree?

I have no issue with that. Heck, I prefer it.

-- Steve
