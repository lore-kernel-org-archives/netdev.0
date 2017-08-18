From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 00/10] sysfs related cleanups
Date: Fri, 18 Aug 2017 13:46:18 -0700
Message-ID: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35357 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdHRUqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:36 -0400
Received: by mail-pg0-f54.google.com with SMTP id v189so70887358pgd.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network sysfs infrastructure changes. Mostly related to using ro_after_init
to make function tables immutable.

Stephen Hemminger (10):
  net: don't decrement kobj reference count on init failure
  net: constify netdev_class_file
  net: make net_class ro_after_init
  net: constify net_ns_type_operations
  net: make net sysfs attributes ro_after_init
  net: drop unused attribute argument from sysfs queue funcs
  net: make BQL sysfs attributes ro_after_init
  net: make queue attributes ro_after_init
  net: mark receive queue attributes ro_after_init
  net: style cleanups

 include/linux/netdevice.h |  15 ++--
 net/core/net-sysfs.c      | 222 ++++++++++++++++++++++------------------------
 2 files changed, 111 insertions(+), 126 deletions(-)

-- 
2.11.0
