From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Mon, 31 Jan 2005 19:06:40 +0100
Message-ID: <16894.29616.137437.542900@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<16879.58333.266843.335475@robur.slu.se>
	<200501201114.49517.jeremy.guthrie@berbee.com>
	<200501310937.30427.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501310937.30427.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > Just wanted to verify that by the term linear search from rtstat/lnstat, you 
 > mean a search of the buckets for a particular hash?
 
 Yes.

 > We're going live tomorrow with the app.  Afterwards I'll load up the no route 
 > caching patch and test that.

Ok! Look at the patch just posted to davem. We should able view and control 
gc_min_interval better.
 
net.ipv4.route.gc_min_interval_ms = 300
net.ipv4.route.gc_min_interval = 0

						--ro
