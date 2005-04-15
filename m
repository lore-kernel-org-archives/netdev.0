From: Baruch Even <baruch@ev-en.org>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Fri, 15 Apr 2005 15:37:34 +0100
Message-ID: <425FD1AE.3060301@ev-en.org>
References: <425C493B.5040206@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <425C493B.5040206@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have no clue *why* it happens, but a hint on when it happens. If I 
remove the ixgb driver from my .config, performance is back to normal. 
Note though that I don't even use the ixgb driver for my tests, it's 
just sitting idle on the machine and connected to nothing (the cisco 
router is turned off to reduce noise polution).

To continue my work I'll disable the ixgb for now.

Baruch

Baruch Even wrote:
> Hello,
> 
> I'm trying to port my H-TCP and SACK improvements to 2.6.11, but I seem 
> to hit performance problems that are unrelated to what I worked on so far.
> 
> My tests show that between 2.6.6 and 2.6.7 the TCP performance dropped 
> considerably.
> 
> The setup for the tests, vanilla kernels, dummynet with 100 Mbit/s and 
> 40ms rtt using the BIC protocol. No patches applied whatsoever.
> 
> iperf tests for 2.6.6 get about 90Mbit/s while 2.6.7 gets 30Mbit/s.
> 
> I was wondering if someone can think of a reason why this happens?
> 
> Is there a way to get the different network related patches between 
> these two versions? I don't have access to bk to get it myself.
> 
> Baruch
> 
