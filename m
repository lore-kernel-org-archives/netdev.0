From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: NAPI poll: why not consider transmit cleanup work before exiting poll mode?
Date: Sun, 24 Aug 2003 10:20:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16200.30020.89263.682253@robur.slu.se>
References: <1061708224.3f4861c063706@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: jc <jchapman@katalix.com>
In-Reply-To: <1061708224.3f4861c063706@webmail.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jc writes:

 Hello!

 > Why don't NAPI drivers consider transmit completion work before doing
 > netif_rx_complete() and re-enabling interrupts?
 
 Well if you see benefits it's worth a test. I think some variant was tested. 
 Did we run into problem when all interrupts disappeared? Make a patchlet 
 for e1000 I'll give this a try in our setup.

 Any experimental data from your tests? 

 > Is this breaking NAPI rules? 

 No it shouldn't.

 Cheers.
						--ro
