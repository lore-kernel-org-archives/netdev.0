From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next (TAKE 3) 0/6] IPv6 over Firewire
Date: Mon, 11 Feb 2013 02:46:41 +0900
Message-ID: <5117DD01.5080008@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38840 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754742Ab3BJRqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 12:46:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is take3 of IPv6 over Firewire.
- Ignore spd and max_payload in ARP/NDP.
- Separate patch for address handler related change
  with some fixes.
- Fix minor typoes.

YOSHIFUJI Hideaki (6):
  firewire net: Ignore spd and max_payload advertised by ARP.
  firewire net: Accept IPv4 and ARP only.
  firewire net: Send L2 multicast via GASP.
  firewire net: Allocate address handler before registering net_device.
  firewire net, ipv4 arp: Extend hardware address and remove
    driver-level packet inspection.
  ipv6: IPv6 over Firewire (RFC3146) support.

 drivers/firewire/Kconfig |    6 +-
 drivers/firewire/net.c   |  322 +++++++++++++++++++++-------------------------
 include/linux/if_arp.h   |   12 +-
 include/net/firewire.h   |   25 ++++
 net/ipv4/arp.c           |   18 ++-
 net/ipv6/addrconf.c      |   20 ++-
 6 files changed, 214 insertions(+), 189 deletions(-)
 create mode 100644 include/net/firewire.h

-- 
1.7.9.5
