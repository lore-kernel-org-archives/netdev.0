From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 21 Jan 2005 16:23:35 +0100
Message-ID: <16881.7799.47441.33803@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501200837.40734.jeremy.guthrie@berbee.com>
	<16879.58333.266843.335475@robur.slu.se>
	<200501201114.49517.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501201114.49517.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




We have to understand the GC details to 100% confident. Some time to digest 
and a may reboot help.

I also mentioned routing without the route hash. No spinning in route
hash and no GC but we trade this for doing a fib lookup for every packet.
Jamal and I started to play with this at last OLS but it's only tested
in lab sofar.

For environments with small number of flows it's probably not a good idea
Length of flows is of course also important. No idea about the result in 
your case.

I have a patch:

ftp:/robur.slu.se:/pub/Linux/net-development/preroute/preroute10.pat

If you feel very brave you can test this. The files to monitor is 
/proc/net/softnet_stat this verify the new packet path.

With rtstat (tot) should show all routed packets. The rate in pps
we are able to achieve.

					--ro
