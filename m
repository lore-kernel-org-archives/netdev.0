From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Tue, 17 May 2005 19:28:29 -0700 (PDT)
Message-ID: <20050517.192829.71087792.davem@davemloft.net>
References: <20050504230731.12be1bc3.davem@davemloft.net>
	<46332e5aa197db91aaf012cf140282b4@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jheffner@psc.edu
In-Reply-To: <46332e5aa197db91aaf012cf140282b4@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 May 2005 22:26:09 -0400

> Though it may be moot by now, I just ran some tests of my own with this 
> patch.  This was on a dual 2.4 GHz Xeon booted with a UP kernel, 
> running iperf over an e1000 at a 1500 byte MTU.  I measured idle CPU by 
> running a process which sits in a gettimeofday() loop.  Numbers are CPU 
> utilization, all turned out +/- 1%.
> 
> No TSO:  86.6%
> Old TSO: 61.0%
> New TSO: 88.5%

Yeah, TSO Reloaded really stinks. :-)

Try the "Super TSO" patch I just posted instead.
