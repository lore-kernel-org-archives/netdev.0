From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Thu, 9 Jan 2003 17:50:07 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.3.96.1030109174736.30393A-100000@gatekeeper.tmr.com>
References: <78180000.1042055993@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Fabio Massimo Di Nitto <fabbione@fabbione.net>,
   Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew McGregor <andrew@indranet.co.nz>
In-Reply-To: <78180000.1042055993@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Jan 2003, Andrew McGregor wrote:

> Probably on the server's side it got an ICMP Host Unreachable or two as 
> some router updated its tables, and decided to close the connection.  The 
> FIN jumped the queue in one/several of the routers in the path, so it got 
> reordered relative to the data.  This would imply that the router in 
> question had its route to you back by the time the FIN got there.
> 
> Wierd, but far from impossible.

Nothing is impossible with routers, including sending ICMP packets using
different routing than TCP (and doing odd things with UDP as well).
Sometimes ICMP will be sent over a low bandwidth link with hopefully less
latency. The phrase "the less traveled way" comes to mind.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.
