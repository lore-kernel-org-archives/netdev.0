From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Fri, 17 Jul 2009 10:08:09 +0200
Message-ID: <19040.12649.517756.281384@robur.slu.se>
References: <20090705173208.GB19477@ami.dom.local>
	<20090705213232.GG8943@linux.vnet.ibm.com>
	<20090705222301.GA3203@ami.dom.local>
	<4A513D0D.5070204@itcare.pl>
	<20090706090207.GB3065@ami.dom.local>
	<4A53D28D.8060409@itcare.pl>
	<20090707235029.GA8207@ami.dom.local>
	<4A565449.4050403@itcare.pl>
	<20090714194100.GA7952@ami.dom.local>
	<19037.34959.327456.662899@robur.slu.se>
	<20090715130526.GA3082@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:36282 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934179AbZGQIIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2009 04:08:11 -0400
In-Reply-To: <20090715130526.GA3082@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:
 > On Wed, Jul 15, 2009 at 09:43:11AM +0200, Robert Olsson wrote:

 > > a very optimistic approach wrt thresholds for root node and adjust to 
 > > settings without the warning. Or maybe now even remove warning totally
 > > with stata counter?
 > 
 > I guess, we could, but maybe let's wait a bit to make sure there is
 > nothing surprising?

Yes if Pawel is running it we we'll get reports. I've no chance to upgrade
any of our routers now.  I've seen this printout in one our routers but we 
don't do "clear ip bgp *" to often and besides we try to use soft re-
configuration inbound.


 > > I think I've got ~6.2 Gbit/s for simplex forwarding using traffic patterns 
 > > we see in/close to Internet core. This w/o route cache on our hi-end opterons
 > > with 8 CPU cores using niu and ixgbe. I'll test again and your patches when
 > > I'm back from vacation.
 > > 

 > Sure, I was mainly aiming at safe defaults (wrt. memory usage), but if
 > tests show there is a better strategy we should go for it.

Routing without route cache is "new" area probably for minority of systems
were caching is not possible. Read BGP routers in core. 

Yes we should have safe defults. Thanks for all your work.

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers 
					--ro
