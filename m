From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: suggestion for routing code improvement
Date: Wed, 10 Apr 2002 22:15:17 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15540.40277.772027.111512@robur.slu.se>
References: <3CB47B90.B4CF1FAD@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3CB47B90.B4CF1FAD@nortelnetworks.com>
List-Id: netdev.vger.kernel.org


Chris Friesen writes:
 > So, what do you guys think?  Is this a reasonable thing to do?  I think that it
 > makes the system nicely symmetrical, as opposed to the asymmetrical handling of
 > current kernels.

 Hello!

 Why not leave the routing policy job to a routing daemon?

 There is risk of routing havoc if the kernel start acting as one.

  L-uu1:/# ip route list | wc -l 
   110441

 This Linux box has 110441 bgp routes. Internet routing is very much
 like a living organism. Routes comes and goes.

 If some interface goes down for some reason the routing daemon gets it's 
 netlink message "link down" and recalcs the routing topologi.

 If the interface comes back the router daemon recalcs again and installs
 appropriate routes for this moment which may very well be different 
 compared to before "link down".

 Cheers.

						--ro
