From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 20 Jan 2005 22:53:30 +0100
Message-ID: <16880.10330.49064.721090@robur.slu.se>
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


Jeremy M. Guthrie writes:

 > >  >    mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
 > >  > 524287     74830     777     0     0     0     0     0         6       0
 > >  > 0     498       0         0    0           40504          1

 > When does GC normally ignore?

 At a min ip_rt_gc_min_interval       = HZ / 2;

 From what I understand your GC runs more often than that.
 Do your understand? Test is in rt_garbage_collect()

					    --ro
