From: sunny12 <johanhen@yahoo.com>
Subject: tg3 driver timeout problems
Date: Mon, 11 Sep 2006 11:18:40 -0700 (PDT)
Message-ID: <6252031.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.nabble.com ([72.21.53.35]:25568 "EHLO talk.nabble.com")
	by vger.kernel.org with ESMTP id S932282AbWIKSSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 14:18:41 -0400
Received: from [72.21.53.38] (helo=jubjub.nabble.com)
	by talk.nabble.com with esmtp (Exim 4.50)
	id 1GMqMi-0007Fr-D1
	for netdev@vger.kernel.org; Mon, 11 Sep 2006 11:18:40 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

we're experiencing serious problems on an productions system running fecora
core5 ( 2.6.17-1.2157_FC5smp #1)  and
running the tg3 driver.
Here is my dmesg output:

tg3.c:v3.59 (June 8, 2006)
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 169
PCI: Setting latency timer of device 0000:02:00.0 to 64
eth0: Tigon3 [partno(BCM95721) rev 4001 PHY(5750)] (PCI Express)
10/100/1000BaseT Ethernet 00:16:17:2a:a8:4d
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1]
TSOcap[1]
eth0: dma_rwctrl[76180000] dma_mask[64-bit]
ACPI: PCI Interrupt 0000:04:06.0[A] -> GSI 19 (level, low) -> IRQ 185
eth1: Tigon3 [partno(BCM95705A50) rev 3003 PHY(5705)] (PCI:33MHz:32-bit)
10/100/1000BaseT Ethernet 00:16:17:2a:a8:4c
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[0]
TSOcap[1]
eth1: dma_rwctrl[763f0000] dma_mask[64-bit]
audit(1154348602.046:4): avc:  denied  { create } for  pid=953 comm="udevd"
name="watchdog" scontext=system_u:system_r:udev_t:

ethtool output

Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: yes
[

The sympton is that sometimes the network is down we cant ping the network
device anymore.
Also from a shell we cant ping the outside world. We can still ping the ipnr
of the network device itself.

A restart of the network using /etc/init.d/network restart does the trick
and the device works again.
I dont think this is related to the TSO problem reported earlier because I
believe its disabled by default.

Any clues, help would be appreciated.
Please let me know if I need to provide additional debug info.

thanks,regards

-- 
View this message in context: http://www.nabble.com/tg3-driver-timeout-problems-tf2254084.html#a6252031
Sent from the netdev forum at Nabble.com.

