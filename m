From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 0/9] Convert features fields from u32 to type u64
Date: Fri, 22 Apr 2011 16:35:58 -0700
Message-ID: <1303515367-25595-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36000 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757009Ab1DVXgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar (9):
  net-dev: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64
  net-ethtool: Convert (hw_/vlan_/wanted_)features fields from u32 type
    to u64.
  net-core: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.
  net-tcp: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.
  net-udp: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.
  net-vlan: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.
  net-bridge: Convert (hw_/vlan_/wanted_)features fields from u32 type
    to u64.
  net-ipv4: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.
  net-ipv6: Convert (hw_/vlan_/wanted_)features fields from u32 type to
    u64.

 include/linux/ethtool.h   |   26 +++++++------
 include/linux/netdevice.h |   86 ++++++++++++++++++++++----------------------
 include/linux/skbuff.h    |    2 +-
 include/net/protocol.h    |    4 +-
 include/net/sock.h        |    8 ++--
 include/net/tcp.h         |    2 +-
 include/net/udp.h         |    2 +-
 net/8021q/vlan_dev.c      |    2 +-
 net/bridge/br_if.c        |    2 +-
 net/bridge/br_private.h   |    2 +-
 net/core/dev.c            |   26 +++++++-------
 net/core/ethtool.c        |   89 ++++++++++++++++-----------------------------
 net/core/skbuff.c         |    2 +-
 net/ipv4/af_inet.c        |    2 +-
 net/ipv4/tcp.c            |    2 +-
 net/ipv4/udp.c            |    2 +-
 net/ipv6/af_inet6.c       |    2 +-
 net/ipv6/udp.c            |    2 +-
 18 files changed, 119 insertions(+), 144 deletions(-)

-- 
1.7.3.1

