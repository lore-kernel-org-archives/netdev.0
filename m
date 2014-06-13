From: Xiangyu Lu <luxiangyu@huawei.com>
Subject: [PATCH 0/5] Backport to 3.10.y for fix CVE-2014-0181
Date: Fri, 13 Jun 2014 01:31:05 +0000
Message-ID: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stable@vger.kernel.org>, <netdev@vger.kernel.org>,
	Xiangyu Lu <luxiangyu@huawei.com>
To: <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:61784 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaFMBo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 21:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,
    This backport fix CVE-2014-0181 which would still be vulnerable in
the latest 3.10.y, please add it.

Eric W. Biederman (5):
  netlink: Rename netlink_capable netlink_allowed
  net: Move the permission check in sock_diag_put_filterinfo to
    packet_diag_dump
  net: Add variants of capable for use on on sockets
  net: Add variants of capable for use on netlink messages
  net: Use netlink_ns_capable to verify the permisions of netlink
    messages

 crypto/crypto_user.c            |  2 +-
 drivers/connector/cn_proc.c     |  2 +-
 drivers/scsi/scsi_netlink.c     |  2 +-
 include/linux/netlink.h         |  7 ++++
 include/linux/sock_diag.h       |  2 +-
 include/net/sock.h              |  5 +++
 kernel/audit.c                  |  4 +--
 net/can/gw.c                    |  4 +--
 net/core/rtnetlink.c            | 20 ++++++-----
 net/core/sock.c                 | 49 +++++++++++++++++++++++++++
 net/core/sock_diag.c            |  4 +--
 net/dcb/dcbnl.c                 |  2 +-
 net/decnet/dn_dev.c             |  4 +--
 net/decnet/dn_fib.c             |  4 +--
 net/decnet/netfilter/dn_rtmsg.c |  2 +-
 net/netfilter/nfnetlink.c       |  2 +-
 net/netlink/af_netlink.c        | 75 ++++++++++++++++++++++++++++++++++++++---
 net/netlink/genetlink.c         |  2 +-
 net/packet/diag.c               |  7 +++-
 net/phonet/pn_netlink.c         |  8 ++---
 net/sched/act_api.c             |  2 +-
 net/sched/cls_api.c             |  2 +-
 net/sched/sch_api.c             |  6 ++--
 net/tipc/netlink.c              |  2 +-
 net/xfrm/xfrm_user.c            |  2 +-
 25 files changed, 177 insertions(+), 44 deletions(-)

-- 
1.8.3.4
