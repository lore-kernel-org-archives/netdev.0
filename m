From: "CIT/Paul" <xerox@foonet.net>
Subject: linux routing problem
Date: Sat, 5 Oct 2002 17:43:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <007701c26cb8$36d7a680$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <Netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am trying to squeeze major performance out of a linux router.   I am
running into heavy problems getting the speed
up to where it needs to be.   It seems the #1 problem is the route
cache.  For every src/dst pair it creates an entry.  Why is this? 
Cisco does not do this.  It uses 100% of the cpu when i'm trying to
route 100,000 pps with say a million src/dst pairs through
the router.  Is there a way to disable it?  Is there a way to speed up
the forwarding rate ? I want to get > 500Kpps out of it.
I'm using Intel E1000 NAPI driver and NAPI kernel (2.4.20).  When i try
and send 100,000 pps through it, the cpu goes to 100% and it deops 80%
of the
packets.  I can see the errors counting up way high on the interface.
If I set an iptables rule to block all the packets in the prerouting
chain, it uses 
16% of the cpu and does not drop many packets (albeit it still drops
some probably due to the driver or napi still being somewhat beta)..
 
Any ideas or suggestions on this and how to get it to work without
dropping packets would be greatly appreciated!!
 
Thanks!

Paul  xerox@foonet.net


[[HTML alternate version deleted]]
