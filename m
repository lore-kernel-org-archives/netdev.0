From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] bonding: introduce bonding options Netlink support
Date: Fri, 18 Oct 2013 17:43:32 +0200
Message-ID: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:44244 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179Ab3JRPnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:42 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so2110219eek.20
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset basically allows "mode" and "active_slave" bonding options
to be propagated and set up via standart RT Netlink interface.

In future other options can be easily added as well.

Jiri Pirko (7):
  bonding: push Netlink bits into separate file
  bonding: move mode setting into separate function
  bonding: move active_slave setting into separate function
  bonding: remove bond_ioctl_change_active()
  bonding: move active_slave getting into separate function
  bonding: add Netlink support mode option
  bonding: add Netlink support active_slave option

 drivers/net/bonding/Makefile       |   2 +-
 drivers/net/bonding/bond_main.c    |  91 ++----------------------
 drivers/net/bonding/bond_netlink.c | 131 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.c | 142 +++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   | 127 ++++++++-------------------------
 drivers/net/bonding/bonding.h      |  19 ++++-
 include/uapi/linux/if_link.h       |  11 +++
 7 files changed, 337 insertions(+), 186 deletions(-)
 create mode 100644 drivers/net/bonding/bond_netlink.c
 create mode 100644 drivers/net/bonding/bond_options.c

-- 
1.8.3.1
