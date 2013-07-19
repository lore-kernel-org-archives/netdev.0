From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] export device physical port id to userspace
Date: Fri, 19 Jul 2013 15:55:48 +0200
Message-ID: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:39613 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308Ab3GSN4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:56:01 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so2427241eaj.13
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:55:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is based on patch by Narendra_K@Dell.com
Once device which can change phys port id during its lifetime adopts this,
NETDEV_CHANGEPHYSPORTID event will be added and driver will call
call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
the change to userspace.

Jiri Pirko (3):
  net: add ndo to get id of physical port of the device
  rtnl: export physical port id via RT netlink
  net: export physical port id via sysfs

 include/linux/netdevice.h    | 18 ++++++++++++++++++
 include/uapi/linux/if_link.h |  1 +
 net/core/net-sysfs.c         | 41 +++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c         | 25 ++++++++++++++++++++++++-
 4 files changed, 84 insertions(+), 1 deletion(-)

-- 
1.8.1.4
