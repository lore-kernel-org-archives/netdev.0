From: Sebastian Alfredo Salvino <sas@noend.com>
Subject: Tigon3 crash when used with any torrent app
Date: Tue, 10 Oct 2006 22:30:23 -0300
Message-ID: <200610102230.23700.sas@noend.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from munchen.servershost.net ([205.234.253.14]:51419 "EHLO
	munchen.servershost.net") by vger.kernel.org with ESMTP
	id S1030434AbWJKB30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 21:29:26 -0400
To: mchan@broadcom.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all

I just upgraded to a custom compiled 2.6.18 kernel on my debian etch box, and 
my network card uses the tg3 driver loaded as a module.

However when I am booted up into 2.6.18 and try to connect to any p2p network 
via BitTorrent, KTorrent, etc., it just hang. 

dmesg output:

tg3: eth0: Link is down.
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.

lspci -v output:

09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752 Gigabit 
Ethernet PCI Express (rev 02)
        Subsystem: Dell Unknown device 01cf
        Flags: bus master, fast devsel, latency 0, IRQ 90
        Memory at dcef0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/3 Enable+
        Capabilities: [d0] Express Endpoint IRQ 0
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [13c] Virtual Channel

I also tried turning off tso with no luck so far.

Do you have any idea what happened to the tg3 driver in 2.6.18 that caused 
this issue and what I could do to fix this issue.


Thanks in advance,
Sebastian
