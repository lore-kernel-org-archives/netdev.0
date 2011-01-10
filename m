From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 13:38:41 +0200
Message-ID: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:33726 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752359Ab1AJLiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 06:38:52 -0500
To: netdev@vger.kernel.org
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements network device grouping and simple manipulation
of groups. Netlink has been update to provide group information and
means of applying changes to members of a specific group via a single
message.

In addition, for testing purposes, we add a parameter to the  dummy
module. If supplied, all devices that are created are assigned to the
specified group.

I will follow up with a patchset which updates iproute2 to use the new
parameters.


Vlad Dogaru (3):
  net_device: add support for network device groups
  net/dummy: add device group parameter
  netlink: support setting devgroup parameters

 drivers/net/dummy.c       |    5 +++++
 include/linux/if_link.h   |    2 ++
 include/linux/netdevice.h |    7 +++++++
 net/core/dev.c            |   12 ++++++++++++
 net/core/rtnetlink.c      |   28 ++++++++++++++++++++++++++++
 5 files changed, 54 insertions(+), 0 deletions(-)

