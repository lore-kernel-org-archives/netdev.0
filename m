From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (TAKE 4) 0/6] IPv6 over Firewire
Date: Tue, 26 Mar 2013 03:25:26 +0900
Message-ID: <51509696.6060600@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	stephan.gatzka@gmail.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net, stefanr@s5r6.in-berlin.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58053 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932576Ab3CYSZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:25:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is take 4 of supporting IPv6 over Firewire (IEEE 1394) based on
RFC3146.

Take 3->4:
- Fix receiving 1394 ARP, which comes without arp$tha.
- Remove rfc3146 unit directory on module exit.
- other minor clean-ups - minimize diffs.

YOSHIFUJI Hideaki (6):
  firewire net: Accept IPv4 and ARP only.
  firewire net: Send L2 multicast via GASP.
  firewire net: Allocate address handler before registering net_device.
  firewire net: Ignore spd and max_payload advertised by ARP.
  firewire net, ipv4 arp: Extend hardware address and remove
    driver-level packet inspection.
  firewire net, ipv6: IPv6 over Firewire (RFC3146) support.

 drivers/firewire/Kconfig |    6 +-
 drivers/firewire/net.c   |  301 +++++++++++++++++++++-------------------------
 include/linux/if_arp.h   |   12 +-
 include/net/firewire.h   |   25 ++++
 net/ipv4/arp.c           |   27 ++++-
 net/ipv6/addrconf.c      |   20 ++-
 6 files changed, 213 insertions(+), 178 deletions(-)
 create mode 100644 include/net/firewire.h

-- 
1.7.9.5
