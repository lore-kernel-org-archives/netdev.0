From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: 04 Oct 2004 09:24:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096896256.1072.4.camel@jzny.localdomain>
References: <20041003213124.GG14344@postel.suug.ch>
	 <20041003213954.GI14344@postel.suug.ch>
	 <20041003161436.50293f9a.davem@davemloft.net>
	 <20041003233647.GN14344@postel.suug.ch>
	 <1096852582.1046.378.camel@jzny.localdomain>
	 <20041004125300.GA15898@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041004125300.GA15898@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-10-04 at 08:53, Thomas Graf wrote:

> I don't think this is possible:
> 
> octave:1> gcd([1000,1024,1200,200,128,100,32,50,122,24])
> ans = 2
> 
> Why not let userspace provide it? ticks/usec and usec/ticks are
> exported via /proc/net/psched.

Easier to define a compile time constant in the kernel.
What you need is to replace the HZ/4 in the creation and execution
of the timer with a constant. And that the value of said constant would
be preferably in the 250ms range.

If you fix this also would be worth fixing the ones in
net/sched/estimator.c


cheers,
jamal
