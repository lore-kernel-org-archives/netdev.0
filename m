From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 09:56:19 +0100
Message-ID: <16870.14259.701771.389978@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121647.30934.jeremy.guthrie@berbee.com>
	<16869.45158.194375.398326@robur.slu.se>
	<200501121723.21969.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121723.21969.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  As your traffic looks sane double your bucket size of the route hash to
 > >  start with. Use the boot option w. rhash_entries. look at rtstat

 > Does it make sense that the driver would kill throughput and force us to 
 > output these types of messages?

 No the other way around... Higher (driver/cpu) throughput/load causes more 
 dst-entries to freed and you reach the max_size*ip_rt_gc_min_interval which
 is a constant and get "dst cache overflow".

 Increasing  rhash_entries is the easieast way to attack this.. Give this
 a try. Monitor with rtstat. You might even have to quadruple your size.

						--ro
