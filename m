From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 08:53:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.085342.41654796.davem@redhat.com>
References: <20030609195652.E35696@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030609204257.L35799@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030609204257.L35799@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Mon, 9 Jun 2003 21:15:18 -0400 (EDT)
   
   Have you tried a different NIC? Not sure how well the 3com is maintained
   for example.

Acutally, the main issue with 3c59x is that it still
uses PIO accesses.  This basically makes it useless
for routing or anything wanting serious latency.

Andrew Morton knows this, but he is such a good maintainer
that he doesn't want to change over the MEM I/O accesses
for fear of breaking something.

It's actually a simple change to make if someone wants to
spend a few cycles on it, then you can see what kind of
performance you'll get with that.
