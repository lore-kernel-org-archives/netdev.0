From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Sat, 22 Mar 2003 21:28:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15996.51038.928453.501527@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D2D8@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jeff Garzik
	 <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D2D8@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:
 > > It's clean but I have some concerns...
 > 
 > Thanks for the feedback.  It's a twist on the previous driver where we
 > disabled/enabled interrupts each time we went in/out of polling.  Trying
 > to avoid those extra PCI writes.  My experience is that you have to
 > really load up the interface to stay in polling mode (get up on step).

 True. Making interrupt delay larger will collect more packets on RX-ring
 and have the two PCI-writes to disable/enables irq to be shared by many 
 packets.

 > Should be the same interrupt rate with or without NAPI.
 
 When NAPI stays in polling there are no interrupts and no extra PCI-writes
 so the high-load situation is optimized. 

 So I fear that interrupts are now added to the high-load situation and this
 will impact top performance -- especially with many NIC's.

 But lets see what comes out from testing.
 
 Cheers.
						--ro
