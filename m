From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 14:53:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004125300.GA15898@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003233647.GN14344@postel.suug.ch> <1096852582.1046.378.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096852582.1046.378.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1096852582.1046.378.camel@jzny.localdomain> 2004-10-03 21:16
> The granularity of the timing is dependent on this - 250msec increments.
> Find a common demonitor for all Hz values which results in something
> along 200ms range and we should be set. 

I don't think this is possible:

octave:1> gcd([1000,1024,1200,200,128,100,32,50,122,24])
ans = 2

Why not let userspace provide it? ticks/usec and usec/ticks are
exported via /proc/net/psched.
