From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 00/21] bridge: complete netlink support
Date: Mon,  8 Feb 2016 12:55:06 +0100
Message-ID: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36065 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcBHL4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:10 -0500
Received: by mail-wm0-f41.google.com with SMTP id p63so109810866wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
After I added support for all attributes in the kernel, it's time to make
use of them in iproute2. I've tested changing/viewing all of the
attributes. I'll send a separate set to add support for the ports
attributes.
For the future, adding a switch to change to "seconds.milliseconds" format
for the timers would be helpful (I've stuck to the currently used clock_t
export to be consistent).

Cheers,
 Nik

Nikolay Aleksandrov (21):
  iplink: bridge: export bridge_id and designated_root
  iplink: bridge: export root_(port|path_cost), topology_change and
    change_detected
  iplink: bridge: export read-only timers
  iplink: bridge: add support for IFLA_BR_GROUP_FWD_MASK
  iplink: bridge: add support for IFLA_BR_GROUP_ADDR
  iplink: bridge: add support for IFLA_BR_VLAN_DEFAULT_PVID
  iplink: bridge: add support for IFLA_BR_MCAST_ROUTER
  iplink: bridge: add support for IFLA_BR_MCAST_SNOOPING
  iplink: bridge: add support for IFLA_BR_MCAST_QUERY_USE_IFADDR
  iplink: bridge: add support for IFLA_BR_MCAST_QUERIER
  iplink: bridge: add support for IFLA_BR_MCAST_HASH_ELASTICITY
  iplink: bridge: add support for IFLA_BR_MCAST_HASH_MAX
  iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_CNT
  iplink: bridge: add support for IFLA_BR_MCAST_STARTUP_QUERY_CNT
  iplink: bridge: add support for IFLA_BR_MCAST_LAST_MEMBER_INTVL
  iplink: bridge: add support for IFLA_BR_MCAST_MEMBERSHIP_INTVL
  iplink: bridge: add support for IFLA_BR_MCAST_QUERIER_INTVL
  iplink: bridge: add support for IFLA_BR_MCAST_QUERY_INTVL
  iplink: bridge: add support for IFLA_BR_MCAST_QUERY_RESPONSE_INTVL
  iplink: bridge: add support for IFLA_BR_MCAST_STARTUP_QUERY_INTVL
  iplink: bridge: add support for netfilter call attributes

 include/utils.h    |   1 -
 ip/iplink_bridge.c | 356 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 356 insertions(+), 1 deletion(-)

-- 
2.4.3
