From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 22:49:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16111.32494.113831.745019@robur.slu.se>
References: <20030616.160856.35828947.davem@redhat.com>
	<20030616232750.GD18484@netnation.com>
	<20030616234937.GE18484@netnation.com>
	<20030617.085921.28790392.davem@redhat.com>
	<16111.18107.699689.704597@robur.slu.se>
	<20030617200721.GA25773@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030617200721.GA25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > I changed Juno to send from a single IP, but it only spat out about
 > 330000 pps, which the dual Tigon3 Opteron box forwarded completely.
 > In order to do a single flow forwarding test, I need to be able to create
 > more input traffic somehow.  Seeing as you wrote pktgen.c, maybe you
 > could help in this department. :)

 OK. See below.

 > >  Also think Simon used only /32 routes... I took "real" Internet-routing
 > >  and made a script so it can be used for experiments. I can make it available.
 > 
 > Yes, I found that area less interesting since Dave M. fixed the hash
 > buckets.  But yes, the prefix scanning will slow it down some.

 Well I  don't think it's so easy as there are 33 zones with prefixes if 
 you have all the routes in one zone I'm not sure what happens thats why 
 I suggested the comparison.

 > Erm.  I can't get fib_stats2.pat to apply against 2.5.71, 2.5.71+davem's
 > join-two-diffs patch, 2.4.21-rc7, or 2.5.71+davem's rtcache changes. 
 > What's it supposed to be against?
 
 Sorry. Our production system and lab uses very patched 2.5.66  
 I'll make a patch for 2.5.71....

 > If I start two threads on the sender (Xeon w/HT), I'm able to push 420000
 > pps, which only partially starts to use NAPI on the Opteron box.  Going
 > to try 2.4 again for a comparison (note: 2.5 seems to have an opposite
 > PCI scan order from 2.4 for the dual Tigon3s).

 Not bad. Replace net/core/pktgen.c in 2.5.X with the version from 
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
 and edit pktgen.sh to suit your needs.

 And see what you got. I'm interested since you are using both different 
 processors as NIC's. Also packet generation itself is interesting as
 it tests driver/HW xmit-path.


 Cheers.
						--ro	
