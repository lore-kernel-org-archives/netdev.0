From: "Nivedita Singhvi" <nivedita@us.ibm.com>
Subject: Re: suggestion for routing code improvement
Date: Wed, 10 Apr 2002 13:41:04 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <OF415414BF.765FDDD4-ON88256B97.0070C808@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
List-Id: netdev.vger.kernel.org



 > > So, what do you guys think?  Is this a reasonable thing
 > > to do?  I think that it
 > > makes the system nicely symmetrical, as opposed to the
 > > asymmetrical handling of current kernels.

 > Hello!

 > Why not leave the routing policy job to a routing daemon?

 > There is risk of routing havoc if the kernel start acting
 > as one.

 > L-uu1:/# ip route list | wc -l
 > 110441

 > This Linux box has 110441 bgp routes. Internet routing is
 > very much like a living organism. Routes comes and goes.

 But is that the norm? Not all linux installations are large
 internet nodes..I'd say at least a significant minority of
 hosts typically have just a few static routes, not running
 a routing daemon, who would be helped by some mechanism to
 auto reinstall routes..(perhaps a generously configurable
 one)

thanks,
Nivedita
