From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 14 Jan 2005 17:05:05 +0100
Message-ID: <16871.60849.905998.527106@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501131328.34449.jeremy.guthrie@berbee.com>
	<16870.58414.767012.96364@robur.slu.se>
	<200501140859.42018.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501140859.42018.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > I ran a script overnight using the modified driver you had given me Robert.  
 > it is interesting that there is almost always errors in the interface even 
 > though we aren't getting dst-cache errors and running ~ 40% free CPU now.  I 
 > am going to switch over to Jesse's driver to see if his instrumentation helps 
 > nail down where the problem is.


 >      rx_packets: 2722676103
 >      tx_packets: 5
 >      rx_bytes: 1171335471
 >      tx_bytes: 398
 >      rx_errors: 8558366
 >      tx_errors: 0
 >      rx_dropped: 1951692

 It might come from be periodic work from GC process correlate drops w. rtatat.

 I think the GC process can be made more smooth but studies and experimentation
 is probably needed as GC process is quite complex. Maybe some looked into this 
 already?

 Also you reported less drops when you increased the size of the RX ring and
 I see higher system performance with smaller RX rings. Both statements may
 actually be true. Big rings size may buffer during periodic work as GC.

 Also I have an experimental patch so you route without the route hash as a 
 comparison. You have to be brave...

 BTW we had this thread going for week,
 
							--ro
