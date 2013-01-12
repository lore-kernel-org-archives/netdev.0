From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 0/6] IPv6 over Firewire (PoC)
Date: Sat, 12 Jan 2013 23:20:53 +0900
Message-ID: <50F17145.9050104@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36667 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752812Ab3ALOUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is my proof of concept changes over the tree.
Code compiles, but untested.

Full changesets are also availble at:
        http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/yoshfuji/linux-2.6-dev.git;a=shortlog;h=refs/heads/v3.7%2Bnet-next%2Bfirewire

I think firewire/net bits should be moved to firewire/net_core.c or something,
which is compiled statically even if FIREWIRE_NET = m.

YOSHIFUJI Hideaki (6):
  ndisc: Move ndisc_opt_addr_space() to include/net/ndisc.h.
  ndisc: Pass net_device to ndisc_fill_addr_option().
  firewire net: Export fwnet_peerinfo structure for ieee1394-specific
    peer information in ARP/NDP.
  firewire net: Export peerinfo handlers.
  firewire net: IPv6 support (RFC3146).
  ipv6: IPv6 over IEEE1394 (RFC3146) support.

 drivers/firewire/Kconfig |    8 +++
 drivers/firewire/net.c   |  125 ++++++++++++++++++++++++++++------------------
 include/net/firewire.h   |   21 ++++++++
 include/net/ndisc.h      |   20 +++++++-
 net/ipv6/addrconf.c      |    4 +-
 net/ipv6/ndisc.c         |   71 +++++++++++++++++++++-----
 net/ipv6/route.c         |    2 +
 7 files changed, 188 insertions(+), 63 deletions(-)
 create mode 100644 include/net/firewire.h

-- 
1.7.9.5
