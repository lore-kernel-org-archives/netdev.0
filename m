From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 19 Jan 2005 23:18:15 +0100
Message-ID: <16878.56487.600435.442912@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501141326.29575.jeremy.guthrie@berbee.com>
	<16874.24305.461492.48668@robur.slu.se>
	<200501190903.45671.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501190903.45671.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  gc_elasticity, gc_interval, gc_thresh etc I would avoid gc_min_interval.

 > I have done a little tweaking. I now hold at around 520K routes in the hash.  
 > I still drop packets every secret_interval but I've upped that counter so I 
 > don't whack all of my hash entries all that often.


 Sounds you done progress. 
 This with relative conservative setting if RX-buffers?

 secret_interval needs special care as it flushes the cache totally.

 What did you tweak? 
 Your output from rtstat will be very interesting.


					 --ro
