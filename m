From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 6 Nov 2002 18:34:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15817.21170.173913.829498@robur.slu.se>
References: <3DC8B85B.5050805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DC8B85B.5050805@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:
 > Here is a patch that makes Tulip support NAPI.  The vast bulk of these
 > changes come from Robert Olsson's ftp site, I just pieced them together.
 > 
 > It works good on my 4-port Tulip NICs, better than the default
 > driver at least (no, I never tried the old HW-Mitigation option).
 > 
 > This patch will also make use of Robert's skb-recycle patch if it's
 > been applied, but through #ifdef magic, it should also work w/out
 > that....

 Hello!

 Well skb recycling is "research" and should be used to challange to vm/slab
 people to start with... And I guess you will get objections about the extra 
 stats as well.

 I see you increased the RX-ring to 1024 pkts. 
 Did you really see any improvement with this?

 Also I would be interested if you have any numbers for recycling patch? 

 Jamal and I spent some days after OLS to test and tune but it wasn't to 
 promising at that time but it's reworked now.
 
 
 Cheers.
						--ro
