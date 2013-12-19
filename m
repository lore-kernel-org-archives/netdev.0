From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH 0/5] bridge: cleanup and fix checkpatch errors
Date: Thu, 19 Dec 2013 13:28:09 +0800
Message-ID: <1387430894-11220-1-git-send-email-tanxiaojun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bart.de.schuymer@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:53007 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab3LSF2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:28:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up and fix some checkpatch errors in bridge driver.

Tan Xiaojun (5):
  bridge: remove unnecessary condition judgment
  bridge: remove unnecessary parentheses
  bridge: add space before '(/{', after ',', etc.
  bridge: change "foo* bar" to "foo *bar"
  bridge: change the position of '{' to the pre line

 net/bridge/br_fdb.c                   |  3 +--
 net/bridge/br_forward.c               |  4 ++--
 net/bridge/br_ioctl.c                 |  2 +-
 net/bridge/br_netfilter.c             |  2 +-
 net/bridge/br_netlink.c               |  3 +--
 net/bridge/br_private.h               |  2 +-
 net/bridge/br_stp_timer.c             |  2 +-
 net/bridge/br_sysfs_if.c              | 20 ++++++++++----------
 net/bridge/netfilter/ebt_log.c        |  2 +-
 net/bridge/netfilter/ebt_snat.c       |  2 +-
 net/bridge/netfilter/ebtable_broute.c |  6 ++----
 net/bridge/netfilter/ebtable_filter.c |  9 +++------
 net/bridge/netfilter/ebtable_nat.c    |  9 +++------
 net/bridge/netfilter/ebtables.c       | 17 ++++++++---------
 14 files changed, 36 insertions(+), 47 deletions(-)

-- 
1.8.0
