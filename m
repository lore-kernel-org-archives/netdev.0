From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 20 Jan 2005 18:01:17 +0100
Message-ID: <16879.58333.266843.335475@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501191950.08567.jeremy.guthrie@berbee.com>
	<16879.38457.4576.598144@robur.slu.se>
	<200501200837.40734.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501200837.40734.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  > 1024 buffers on the RX of eth3.
 > >  >
 > >  > echo 86400 > /proc/sys/net/ipv4/route/secret_interval
 > >  > echo 524288 > /proc/sys/net/ipv4/route/gc_thresh
 > >
 > >  rhash_entries?
 > I left that at 2.4 million.
 > 
 > >  > It appears to be cruising right along now.


 >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc 
 > GC: tot ignored goal_miss ovrf HASH: in_search out_search
 > 524291     74169     779     0     0     0     0     0         2       0 
 > 1610369017     516       0         0    0           43612          0
 > 524287     74830     777     0     0     0     0     0         6       0      
 > 0     498       0         0    0           40504          1
 > 524285     77458     949     0     0     0     0     0         4       0      
 > 0     619       0         0    0           42731          1


 Linear search is under control and number of dst entries very high but very
 constant at the cost of calling GC a number of times second. But I don't 
 understand why we do not see any GC ignored. Did you ever write to gc_min_interval 
 in proc? Never seen rtstat's like this but it seems to do the job.

						  --ro
