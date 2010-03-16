From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] several minor Netlink fixes
Date: Wed, 17 Mar 2010 00:29:34 +0100
Message-ID: <20100316232247.4185.19426.stgit@decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58953 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970Ab0CPX3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 19:29:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This patchset contains a couple of fixes for Netlink related stuff. More
relevantly, a path that allows to set ENOBUFS when NETLINK_NO_ENOBUFS is
set (that should not happen). It follows the corresponding fix for
ctnetlink. This patchset closes with one fix for a unaligned access.

Please apply! Thanks!

---

Pablo Neira Ayuso (3):
      netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
      netfilter: ctnetlink: fix reliable event delivery if message building fails
      netlink: fix unaligned access in nla_get_be64()


 include/linux/netfilter/nfnetlink.h  |    2 +-
 include/linux/netlink.h              |    2 +-
 include/net/netlink.h                |    6 +++++-
 net/netfilter/nf_conntrack_netlink.c |    4 +++-
 net/netfilter/nfnetlink.c            |    4 ++--
 net/netlink/af_netlink.c             |   13 +++++++++++--
 6 files changed, 23 insertions(+), 8 deletions(-)

