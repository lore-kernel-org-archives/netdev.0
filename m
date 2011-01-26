From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 0/3] iproute2: support for device groups
Date: Wed, 26 Jan 2011 18:41:23 +0200
Message-ID: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:43643 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752920Ab1AZQla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 11:41:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds userspace support for network device groups.
There is support for setting device groups, listing only interfaces of a
specific group, and setting basic device parameters for all interfaces
in a group.

Changes since version 2:
 * groups now have names. The mapping between names and numbers (which
   are used by the kernel) is in /etc/iproute2/group_map.
 * the ip man page and usage display function have been updated to
   reflect the new functionality.

Changes since version 1:
 * a single attribute is used for both setting the group of a device and
   manipulating an entire group.


Vlad Dogaru (3):
  iproute2: add support for setting device groups
  iproute2: support listing devices by group
  iproute2: support setting device parameters by group

 etc/iproute2/group_map    |    2 +
 include/linux/if_link.h   |    1 +
 include/linux/netdevice.h |    2 +-
 include/utils.h           |    5 +++-
 ip/ip_common.h            |    2 +
 ip/ipaddress.c            |   14 ++++++++++
 ip/iplink.c               |   60 ++++++++++++++++++++++++++++++++++++++++++---
 ip/link_veth.c            |    3 +-
 lib/utils.c               |   41 ++++++++++++++++++++++++++++++
 man/man8/ip.8             |   31 ++++++++++++++++++++---
 tc/m_ematch.c             |   39 -----------------------------
 11 files changed, 150 insertions(+), 50 deletions(-)
 create mode 100644 etc/iproute2/group_map

