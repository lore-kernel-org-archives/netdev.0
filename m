From: "CIT/Paul" <xerox@foonet.net>
Subject: Bad problem with route cache using as a large router
Date: Mon, 17 Feb 2003 00:15:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <004301c2d643$92567e10$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm having a BAD cpu usage problem using linux routers for routing an
extreme number of flows at high pps rates.
Take for instance, random source ips, single destination, or random
destinations at 100kpps and it destroys the route cache even on a dual
p3 1.26.
The k_softirqd processes spend their entire times updating the running
gc on the cache and the machine can't do anything else.  Is there a way
to TURN OFF
the route cache (Like Cisco) so that it doesn't exist any more, maybe
use more of an 'adjacency cache' ?
 
Thanks!

Paul


[[HTML alternate version deleted]]
