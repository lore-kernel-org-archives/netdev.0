From: bert hubert <ahu@ds9a.nl>
Subject: 2.6.0-test4, 2.5.47, child qdiscs, parent not filled out?
Date: Wed, 3 Sep 2003 12:28:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903102803.GA11876@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: devik@cdi.cz
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Devik (I hope we can be friends again :-)), others,

I'm currently working on the wondershaper 2.0 which is going to be much more
a massmarket product (still GPL, no worries), and I'm wondering why the
parent field of child qdiscs isn't filled out?

If I create a cbq with several classes, and attach a qdisc to those classes,
a later netlink dump (RTM_GETQDISCS) returns parent as 0:0 for that qdisc,
is this right?

Same holds for HTB and child qdiscs. Basically, I can't find a way to figure
out where qdiscs are actually attached. Or should I look for that in xstats?

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
