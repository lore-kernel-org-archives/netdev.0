From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 12:36:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16074.1339.3673.938923@robur.slu.se>
References: <20030520082217.GC978@udine>
	<20030520.012824.85398613.davem@redhat.com>
	<20030520085724.GD978@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@Sun.COM>
In-Reply-To: <20030520085724.GD978@udine>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Eric Lemoine writes:
 > >    From: Eric Lemoine <Eric.Lemoine@Sun.COM>
 > >    Date: Tue, 20 May 2003 10:22:17 +0200
 > >    
 > >    Any comments regarding the following patch?

 I think it will make any use of "raw" dev->hard_start_xmit" impossible. 
 Which is what pktgen uses.

 > > I understand why it is valid, etc., but why do we even want to do
 > > this?  It is not like this dead-loop detection stuff is a hot-path or
 > > anything like that.
 > 
 > I've implemented a prototype that uses per-CPU kernel threads for
 > processing packets coming in from a single interface. The idea is to
 > apply multiple CPUs to a single network interface to be able to have
 > multiple CPUs simultaneously pumping data into the network. So in my
 > case, I have lots of cpu_collisions and running the tx softirq to do
 > nothing may lower the performances. Anyway, even though my patch may
 > help me, it may indeed be irrelevant to the stock kernel.

 Sounds like a project at least having packet reordering and cache bouncing 
 in mind.
 

 Cheers.
						--ro
 
