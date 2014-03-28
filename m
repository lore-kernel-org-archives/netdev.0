From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: document sysfs entries
Date: Fri, 28 Mar 2014 14:25:56 -0700
Message-ID: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:45901 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaC1V0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:26:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so5392388pdj.3
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 14:26:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset attempts to document the basic set of sysfs entries that are
exposed by netdevices in /sys/class/net/<iface>/

I did not go before the pre-git era, so the oldest entries are marked with
the 2.6.12 kernel version and dated of April 2005.

Future patches will document the queues/ and statistics/ directories as well.

Florian Fainelli (2):
  net: sysfs: add Documentation entries for basic set of attributes
  net: export NET_ADDR_* values to user-space API

 Documentation/ABI/testing/sysfs-class-net | 199 ++++++++++++++++++++++++++++++
 include/linux/netdevice.h                 |   7 --
 include/uapi/linux/netdevice.h            |   6 +
 3 files changed, 205 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net

-- 
1.8.3.2
