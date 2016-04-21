From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 0/4] libnl: enhance API to ease 64bit alignment for attribute
Date: Thu, 21 Apr 2016 18:58:23 +0200
Message-ID: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:52616 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbcDUQ6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:58:47 -0400
In-Reply-To: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a proposal to add more helpers in the libnetlink to manage 64-bit
alignment issues.
Note that this series was only tested on x86 by tweeking
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS and adding some traces.

The first patch adds helpers for 64bit alignment and other patches
use them.

We could also add helpers for nla_put_u64() and its variants if needed.

v1 -> v2:
 - remove patch #1
 - split patch #2 (now #1 and #2)
 - add nla_need_padding_for_64bit()

 include/net/netlink.h          | 39 +++++++++++++----
 include/uapi/linux/rtnetlink.h |  1 +
 lib/nlattr.c                   | 99 ++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c           | 22 +++-------
 net/ipv4/ipmr.c                |  4 +-
 net/ipv6/ip6mr.c               |  4 +-
 6 files changed, 140 insertions(+), 29 deletions(-)

Comments are welcomed,
Regards,
Nicolas
