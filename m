From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 23:22:57 +0100
Message-ID: <16869.41793.881555.323604@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<16869.34519.31321.977100@robur.slu.se>
	<200501121445.51780.jeremy.guthrie@berbee.com>
	<200501121605.12943.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121605.12943.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > I am now getting some push back from the project manager on this performance 
 > problem.  I am wondering if you think faster CPUs will 
 > a)  help relieve the symptoms of this problem
 > b)  not help because now we will hit a '# of routes in the route-cache' 
 > problem
 > c)  or will help to a point till the # interrupts come back and bite us.

 Back out the patch I sent.and have hardirq's to run RX-softirq as you 
 did before but something is very wrong. You didn't answer if there were
 other load on the machine...

 route-cache can probably be tuned you as have four times the linear seach
 I see in one PIII system at 110 kpps w. production traffic.

 Of course the non-engineering solution is to buy more CPU... :-)

					       --ro
