From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Tue, 12 Apr 2005 16:07:52 -0700
Message-ID: <20050412160752.46c82f0c@dxpl.pdx.osdl.net>
References: <425C493B.5040206@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <425C493B.5040206@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Apr 2005 23:18:35 +0100
Baruch Even <baruch@ev-en.org> wrote:

> Hello,
> 
> I'm trying to port my H-TCP and SACK improvements to 2.6.11, but I seem 
> to hit performance problems that are unrelated to what I worked on so far.
> 
> My tests show that between 2.6.6 and 2.6.7 the TCP performance dropped 
> considerably.

Remember 2.6.6 had the old hyper aggressive and over correcting version
of BIC.

> The setup for the tests, vanilla kernels, dummynet with 100 Mbit/s and 
> 40ms rtt using the BIC protocol. No patches applied whatsoever.
> 
> iperf tests for 2.6.6 get about 90Mbit/s while 2.6.7 gets 30Mbit/s.

Haven't measured old kernels recently. But haven't seen that with the
newest stuff I tested last night. At 40ms delay  with netem
over 1G to 100M bridge.
	Reno	99.6
	Vegas	61.6
	BIC	  97.8
	Hstcp	 99.4
	Westwood 99.4

What are your sysctl settings. 

> I was wondering if someone can think of a reason why this happens?
> 
> Is there a way to get the different network related patches between 
> these two versions? I don't have access to bk to get it myself.
> 
> Baruch
