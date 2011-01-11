From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v2 iproute2 0/3] ip link: add support for network device groups
Date: Tue, 11 Jan 2011 18:35:46 +0200
Message-ID: <1294763749-9997-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60294 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932282Ab1AKQfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 11:35:52 -0500
To: netdev@vger.kernel.org
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds userspace support for network device groups.
There is support for setting device groups, listing only interfaces of a
specific group, and setting basic device parameters for all interfaces
in a group.

The patches use the IFLA_GROUP attribute, for which I posted pathes in a
different set.

Changes since version 1:
 * a single attribute is used for both setting the group of a device and
   manipulating an entire group.

Vlad Dogaru (3):
  ip link: add support for setting device groups
  ip link: support listing devices by group
  ip link: support setting device parameters by group

 include/linux/if_link.h   |    2 +
 include/linux/netdevice.h |    2 +-
 include/utils.h           |    3 +-
 ip/ipaddress.c            |   14 +++++++++++
 ip/iplink.c               |   55 +++++++++++++++++++++++++++++++++++++++++++-
 ip/link_veth.c            |    3 +-
 6 files changed, 74 insertions(+), 5 deletions(-)

