From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:33:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.093349.48511220.davem@redhat.com>
References: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
	<3EE5C7E9.6090401@monmouth.com>
	<20030610080901.M37190@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jsd@monmouth.com, pekkas@netcore.fi, ralph+d@istop.com, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030610080901.M37190@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Tue, 10 Jun 2003 08:12:58 -0400 (EDT)

   Theres another dimension actually: mostly driven by BSD mbuff style
   packet allocation; some tests show that some vendors are optimized
   for certain packet sizes, Linux skbuffs dont have this problem.

Well, the most amusing part for me is that if you read all the
papers on TCP congestion algorithms you'd think that routers
dropped based upon packet sizes since the majority work on
multiple of MSS this and multiple of MSS that. :)

Routers drop packets, period.  They do so using a variety of selection
schemes (RED, CBQ, actually just egrep net/sched/sch_*.c :) but you're
contribution to the router's work is measured in terms of packets and
time when you come right down to it.
