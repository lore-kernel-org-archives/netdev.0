From: Sridhar Samudrala <sri@us.ibm.com>
Subject: ip6_route_output() does not fill in the src. addr.
Date: Wed, 18 Dec 2002 15:12:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0212181454260.9875-100000@dyn9-47-18-86.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The ipv6 version of the 'get route entry' function ip6_route_output() does not
fill in the source address of the route even when a valid appropriate source 
address is passed. 
Is this the expected behavior or a bug which is going to be fixed in the future 
releases of 2.5?   

The ipv4 version 'ip_route_output_key()' works as expected.

SCTP calls these routines to get and cache a route entry and uses the cached
entry to fill in skb->dst before passing the skb to ip. 

Thanks
Sridhar
