From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 20:57:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16009.57620.391630.720667@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D30D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jason Lunz
	 <lunz@falooley.org>, Jeff Garzik <jgarzik@pobox.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D30D@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:

 > Thanks for you help guys!  I broke NAPI (don't hate me) and then went on
 > vacation, so I apologize for not responding sooner.  I like what you've
 > come up with here, so I'll turn the patch around for Jeff to update 2.5
 > e1000.
 > 
 > > +       e1000_clean_tx_irq(adapter);
 > > +       e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 > 
 > Just curious, why give priority to Tx over Rx?

 Hello!

 Honestly not too much thinking... well we can always argue by having
 Rx last we get more packets per poll. Yes we should test the other
 way around.

 Also still some concern by having the watchdog kicked in e1000_intr 
 wouldn't e1000_clean feel better? 

 It would also be interesting to see what happens if we remove the flush when 
 enable interrupts in e1000_clean?

 I've tested the patch that removes some of the PCI-accesses. I think I sent
 you some version of it. Anyway it seems to have some effects. If Jason has 
 time we will get some numbers from his instrument/setup.

 Cheers.
						--ro
 
 
