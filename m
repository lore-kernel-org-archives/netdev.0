From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 1 Dec 2004 17:47:24 +0100
Message-ID: <16813.62876.180869.404122@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
	<41A76085.7000105@draigBrady.com>
	<1101499285.1079.45.camel@jzny.localdomain>
	<16811.8052.678955.795327@robur.slu.se>
	<20041129121604.47eb6593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net, jorge.finochietto@polito.it,
        galante@polito.it, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041129121604.47eb6593.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > >  Did I dream or did someone tell me that S2IO 
 > >  could have several TX ring that could via MSI be routed to proper cpu?
 > 
 > One of Sun's gigabit chips can do this too, except it isn't
 > via MSI, the driver has to read the descriptor to figure out
 > which cpu gets the software interrupt to process the packet.
 > 
 > SGI had hardware which allowed you to do this kind of stuff too.
 > 
 > Obviously the MSI version works much better.
 > 
 > It is important, the cpu selection process.  First of all, it must
 > be calculated such that flows always go through the same cpu.
 > Otherwise TCP sockets bounce between the cpus for a streaming
 > transfer.
 > 
 > And even this doesn't avoid all such problems, TCP LISTEN state
 > sockets will still thrash between the cpus with such a "pick
 > a cpu based upon" flow scheme.
 > 
 > Anyways, just some thoughts.

 Thanks for the the info. Well we'll be forced to get into those problems when
 the HW is capable. I'll guess it will be w. the 10 GIGE cards.

					     --ro
