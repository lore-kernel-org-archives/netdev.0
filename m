From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH 0/3] iproute2: ip link: add support for network device groups
Date: Mon, 10 Jan 2011 13:39:16 +0200
Message-ID: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:33761 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753627Ab1AJLjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 06:39:23 -0500
To: netdev@vger.kernel.org
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds userspace support for network device groups.
There is support for setting device groups, listing only interfaces of a
specific group, and setting basic device parameters for all interfaces
in a group.

The patches use the IFLA_GROUP and IFLA_FILTERGROUP messages, for which
I posted pathes in a different set.


Vlad Dogaru (3):
  ip link: add support for setting device groups
  ip link: support listing devices by group
  ip link: support setting device parameters by group

 include/linux/if_link.h   |    3 ++
 include/linux/netdevice.h |    2 +-
 include/utils.h           |    3 +-
 ip/ipaddress.c            |   14 +++++++++++
 ip/iplink.c               |   54 +++++++++++++++++++++++++++++++++++++++++++-
 ip/link_veth.c            |    3 +-
 6 files changed, 74 insertions(+), 5 deletions(-)

