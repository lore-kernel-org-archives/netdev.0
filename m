From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: strange e1000 interface freeze
Date: Wed, 11 Aug 2004 16:26:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16666.11408.446131.763707@robur.slu.se>
References: <411757CA.4010401@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <411757CA.4010401@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


P@draigBrady.com writes:
 > I've been able to reproduce an situation here
 > where the interface freezes on a platform
 > where a continuous stream of about 8000 packets
 > per second are being received. It usually takes

 > By lock up I mean that the interface records all packets
 > as fifo errors, and it receives only 1 interrupt every 2 seconds.
 > Note the other NAPI interface works fine (at about 7.5K interrupts/s).

 Weird. We had a problem with a e1000 in one particular PCI-slot were the 
 NIC was dropping packets no other clues. Decreasing PCI-bus speed from 133 
 to 100 MHz solved this problem. There are two chip revs. Anvik I and II.
 Anvik I had problems in some architectures from what I understood.

 Cheers.
						--ro
