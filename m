From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: More 2.4.22pre10 ACPI breakage
Date: Mon, 11 Aug 2003 00:22:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16182.50618.69504.611254@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01022292E1@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, "Samuel Flory" <sflory@rackable.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E01022292E1@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Feldman, Scott writes:

 > NAPI always-poll mode...that would be fun to play with...

 > Is this what you're thinking: 1) block any place the driver enables
 > interrupts so interrupts stay disabled, 2) ignore netif_rx_complete so
 > we stay in polling mode, 3) ignore return code from netdev->poll.
 > 
 > For 1), the driver needs some way to know that we're in always-poll-mode
 > so enabling interrupts is a nop.
 > 

 I will work but I doubt the usefulness of it as we spin aggressively even
 when there low or no load. This as NAPI tries to serve your dev->poll 
 fastest possible given the fairness conditions are met.
 
 I could think of a variant... 

 As dev->poll is callback we could possibly schedule (and delay) via a timer 
 or something with in turn does the the schedule dev->poll for us. We have 
 to return netif_rx_complete and have RX-buffers etc.


 > Just thinking out loud - haven't tried any of this.

 Same here... :-)

 Cheers.
						--ro
