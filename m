From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] fix bonding slave info API (sysfs and netlink)
Date: Wed, 22 Jan 2014 09:05:52 +0100
Message-ID: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:39881 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaAVIGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:02 -0500
Received: by mail-ee0-f43.google.com with SMTP id c41so4610444eek.16
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main part of this patchset is the introduction of a generic way how
to get/set info of slaves unsing rtnl_link_ops.

Jiri Pirko (5):
  bonding: change name of sysfs dir for bonding slaves
  rtnetlink: put "BOND" into nl attribute names which are related to
    bonding
  rtnetlink: provide api for getting and setting slave info
  bonding: convert netlink to use slave data info api
  rtnetlink: remove ndo_get_slave

 drivers/net/bonding/bond_main.c        |   1 -
 drivers/net/bonding/bond_netlink.c     |  33 ++++--
 drivers/net/bonding/bond_sysfs_slave.c |   2 +-
 drivers/net/bonding/bonding.h          |   1 -
 include/linux/netdevice.h              |   5 -
 include/net/rtnetlink.h                |  14 +++
 include/uapi/linux/if_link.h           |  21 ++--
 net/core/rtnetlink.c                   | 209 ++++++++++++++++++++++-----------
 8 files changed, 190 insertions(+), 96 deletions(-)

-- 
1.8.3.1
