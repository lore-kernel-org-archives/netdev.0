From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 0/9] net: small improvement
Date: Thu,  8 Oct 2015 21:28:53 +0800
Message-ID: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:39574 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757642AbbJHNdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 09:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes several functions in net return bool to improve
readability and/or simplicity because these functions only use one
or zero as their return value.

No functional changes.

Yaowei Bai (9):
  net/netlink: lockdep_genl_is_held can be boolean
  net/ieee80211: ieee80211_is_* can be boolean
  net/nfnetlink: lockdep_nfnl_is_held can be boolean
  net/can: can_dropped_invalid_skb can be boolean
  net/dccp: dccp_list_has_service can be boolean
  net/dccp: dccp_bad_service_code can be boolean
  net/inetdevice: inet_ifa_match can be boolean
  net/inetdevice: bad_mask can be boolean
  net/core: lockdep_rtnl_is_held can be boolean

 include/linux/can/dev.h             |  6 +--
 include/linux/dccp.h                |  6 +--
 include/linux/genetlink.h           |  2 +-
 include/linux/ieee80211.h           | 76 ++++++++++++++++++-------------------
 include/linux/inetdevice.h          | 10 ++---
 include/linux/netfilter/nfnetlink.h |  6 +--
 include/linux/rtnetlink.h           |  6 +--
 net/core/rtnetlink.c                |  2 +-
 net/dccp/dccp.h                     |  4 +-
 net/netfilter/nfnetlink.c           |  2 +-
 net/netlink/genetlink.c             |  2 +-
 11 files changed, 61 insertions(+), 61 deletions(-)

-- 
1.9.1
