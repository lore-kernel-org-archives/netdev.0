From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 17:04:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001170456.3ec52222.davem@davemloft.net>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
	<20041001121123.19511403.ak@suse.de>
	<20041001124733.1ac4266a.davem@davemloft.net>
	<20041001195146.GA23046@wotan.suse.de>
	<20041001125643.30c6830f.davem@davemloft.net>
	<20041001231939.GC23046@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com, jheffner@psc.edu,
        herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041001231939.GC23046@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Oct 2004 01:19:39 +0200
Andi Kleen <ak@suse.de> wrote:

> > As mentioned, the TCP receive buffer auto-tuning takes care
> > of all of this in 2.6.6 and later.  It's just 2.6.5 doesn't
> 
> How do you explain the 2-4MB/s less with manually increased 
> receive buffers? 

Some scheduling differences, I suppose.

Frankly, I've done what I can with the TSO stuff at this point.

All I get from you are "it's slower" and no code, I've had to
write and fix and debug everything for you.  The performance
is close or on-par to non-TSO and more importantly TSO abides
by the congestion window and MSS values properly now.  That's
10 times more important than 2-4MB/s performance difference.

Or maybe I should revert all of the TSO work so that all SpecWEB
submissions done with 2.6.x kernels get invalidated?
