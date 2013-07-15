From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/3] export device physical port id to userspace
Date: Mon, 15 Jul 2013 19:07:04 +0200
Message-ID: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
Cc: Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:53713 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3GORHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 13:07:14 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so7853920eaj.17
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 10:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is based on patch by Narendra_K@Dell.com
Once device which can change phys port id during its lifetime adopts this,
NETDEV_CHANGEPHYSPORTID event will be added and driver will call
call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagete
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
