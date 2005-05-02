From: Stephen Hemminger <shemminger@osdl.org>
Subject: Mystery packet killing tg3
Date: Mon, 2 May 2005 16:24:05 -0700
Message-ID: <20050502162405.65dfb4a9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While I was on vacation, OSDL did some networking changes that seems to aggravate some
existing bug in the tg3 driver. Could be some VLAN related garbage, not sure.

System is 2 CPU AMD64 and the tg3 is on the motherboard.

I am seeing messages like:
 eth0: Tigon3 [partno(BCM95703A30) rev 1002 PHY(5703)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:60:53:08:18
 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0] 
 tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2

Any clues?
