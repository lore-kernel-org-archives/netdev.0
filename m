From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 17:02:16 +0100
Message-ID: <16869.18952.22825.744294@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501111118.00601.jeremy.guthrie@berbee.com>
	<16868.7936.512676.178828@robur.slu.se>
	<200501111930.35689.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501111930.35689.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > I am up for pushing it if you do not think it is a waste of time.  Based on 
 > what I am seeing it looks like I just need a faster CPU to do the work.  My 
 > goal would be to hit zero dropped packets w/ 10-15% CPU to spare but I fail 
 > to see how that will happen on this box.  Do you concur that it would be 
 > highly unlikely I would be able to get that kind of performance increase?

 Well we can try to decrease some of the linear search in the route hash
 once we understand why we see all the RX interrupts. 

						   --ro
