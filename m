From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v2 0/2] net: add device groups
Date: Tue, 11 Jan 2011 18:35:22 +0200
Message-ID: <1294763724-9927-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60277 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab1AKQfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 11:35:31 -0500
To: netdev@vger.kernel.org
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements network device grouping and simple manipulation
of groups. Netlink has been updated to provide group information and
means of applying changes to members of a specific group via a single
message.

I will follow up with a patchset which updates iproute2 to use the new
parameters.

Changes since version 1:
 * we avoid adding a new attribute type by using the following
   convention: if no device name is specified, the interface index is
   negative, and there is a group specified, we change parameters for
   the whole group.
 * the dummy module is no longer modified to include an initial group
   for the devices it creates. The user is responsible for moving them
   to a different group by means of the provided netlink interface.

Vlad Dogaru (2):
  net_device: add support for network device groups
  netlink: support setting devgroup parameters

 include/linux/if_link.h   |    1 +
 include/linux/netdevice.h |    7 +++++++
 net/core/dev.c            |   12 ++++++++++++
 net/core/rtnetlink.c      |   38 ++++++++++++++++++++++++++++++++++----
 4 files changed, 54 insertions(+), 4 deletions(-)

