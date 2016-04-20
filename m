From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/4] libnl: enhance API to ease 64bit alignment for attribute
Date: Wed, 20 Apr 2016 10:57:31 +0200
Message-ID: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56428 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbcDTI5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 04:57:51 -0400
In-Reply-To: <20160419.195009.1052027353987244150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a proposal to add more helpers in the libnetlink to manage 64-bit
alignment issues.
Note that this series was only tested on x86.

The first patch is a fix (bug seen by code review only unless I've missed
something).
The second patch adds helpers and uses it for IFLA_STATS64.
The last two patches use the new API to align mcast stats.

We could also add helpers for nla_put_u64() and its variants.

 include/net/netlink.h          |  10 +++-
 include/uapi/linux/rtnetlink.h |   1 +
 lib/nlattr.c                   | 107 +++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c           |   9 +---
 net/ipv4/ipmr.c                |   4 +-
 net/ipv6/ip6mr.c               |   4 +-
 6 files changed, 123 insertions(+), 12 deletions(-)

Comments are welcomed,
Regards,
Nicolas
