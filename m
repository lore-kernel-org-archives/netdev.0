From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 06:22:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.062217.48383829.davem@redhat.com>
References: <20030609080430.I34540@shell.cyberus.ca>
	<20030609.053218.54202815.davem@redhat.com>
	<20030609091907.Y34702@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030609091907.Y34702@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Mon, 9 Jun 2003 09:22:11 -0400 (EDT)
   
   I dont think youll see much benefit with 1 or 2 entries. I was thinking
   more along the lines of people with over 100K entries total;

You simply don't want the chains to get that long.  In my experience,
even with prefetching tricks, past 2 or 3 entry deep hash chains you
run into serious problems.

TCP has the same issue BTW, in fact DoS-like behavior is the common
thing there.  Every time you create a new TCP connection on a server
it's exactly like a routing cache miss.

   Let me run with this and get back to you.

Ok.
