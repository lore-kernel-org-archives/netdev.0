From: pablo@netfilter.org
Subject: [PATCH 0/2] [v3] netlink_kernel_create updates
Date: Sat,  8 Sep 2012 14:53:52 +0200
Message-ID: <1347108834-15429-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43846 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584Ab2IHMzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 08:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

Fixed the infiniband issue. New round of these patches.

Please, apply.

Thanks!

Pablo Neira Ayuso (2):
  netlink: kill netlink_set_nonroot
  netlink: hide struct module parameter in netlink_kernel_create

 crypto/crypto_user.c                |    3 +--
 drivers/connector/connector.c       |    3 +--
 drivers/infiniband/core/netlink.c   |    2 +-
 drivers/scsi/scsi_netlink.c         |    2 +-
 drivers/scsi/scsi_transport_iscsi.c |    3 +--
 drivers/staging/gdm72xx/netlink_k.c |    2 +-
 include/linux/netlink.h             |   22 +++++++++++++--------
 kernel/audit.c                      |    3 +--
 lib/kobject_uevent.c                |    5 ++---
 net/bridge/netfilter/ebt_ulog.c     |    3 +--
 net/core/rtnetlink.c                |    4 ++--
 net/core/sock_diag.c                |    3 +--
 net/decnet/netfilter/dn_rtmsg.c     |    3 +--
 net/ipv4/fib_frontend.c             |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    3 +--
 net/netfilter/nfnetlink.c           |    2 +-
 net/netlink/af_netlink.c            |   36 ++++++++++++++++-------------------
 net/netlink/genetlink.c             |    6 ++----
 net/xfrm/xfrm_user.c                |    2 +-
 security/selinux/netlink.c          |    5 ++---
 20 files changed, 52 insertions(+), 62 deletions(-)

-- 
1.7.10.4
