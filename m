From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 22:30:17 +0100
Message-ID: <16862.65385.9009.742742@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501071414.05126.jeremy.guthrie@berbee.com>
	<16862.62424.180929.680029@robur.slu.se>
	<200501071506.57811.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501071506.57811.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > lnstat isn't giving me anything other than zeros.  

 Crap.

 > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  
 > out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss 
 > gc_dst_overflow in_hlist_search out_hlist_search
 
 > 0000f91e  15b1ddab 0b69a32c 00000000 00000000 00001b0a 00001fbd 00000000  
 > 00066f65 0000b943 00000000 087b80a1 0878e81a 00000256 00000000 ca08c77d 
 > 0020e549
 
 
 > 0000fb3e  15ff4696 0b6bbb65 00000000 00000000 00001b10 00001fc1 00000000  
 > 00067111 0000b974 00000000 087d9903 087b0003 00000256 00000000 cb58b399 
 > 0020ee79
 
 85 kpps and 2287 lookups/sec as a 60 sec average. Pretty nice load yes. 
 Where did you get the load? 
 Try see if you fix lnstat :-) it would be nice to see the route dynamics. 
 Or use the try the rtstat I pointed to. 

 And apply the e1000 patch I sent and make a test run. 

 I'll have a beer and give up for tonight...

		  				--ro
