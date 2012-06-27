From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/7] Get rid of RTA*() macros
Date: Wed, 27 Jun 2012 11:36:09 +0200
Message-ID: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754990Ab2F0JgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset gets rid of all the RTA_PUT() and RTA_GET()
macros and makes use of the type-safe netlink API variants
where applicable.

I did my best to test these patches but I do not own any
decnet hardware so the decnet part is compile tested only.

Thomas Graf (7):
  unix_diag: Do not use RTA_PUT() macros
  sock_diag: Do not use RTA_PUT() macros
  inet_diag: Do not use RTA_PUT() macros
  ipmr: Do not use RTA_PUT() macros
  ip6mr: Do not use RTA_PUT() macros
  decnet: Do not use RTA_PUT() macros
  netlink: Get rid of obsolete rtnetlink macros

 include/linux/rtnetlink.h |  129 ---------------------------------------------
 net/core/rtnetlink.c      |   13 -----
 net/core/sock_diag.c      |   12 +---
 net/decnet/dn_fib.c       |    8 +++
 net/decnet/dn_route.c     |   61 +++++++++++++--------
 net/decnet/dn_table.c     |   69 ++++++++++++++----------
 net/ipv4/inet_diag.c      |  112 ++++++++++++++++++--------------------
 net/ipv4/ipmr.c           |   28 +++++-----
 net/ipv6/ip6mr.c          |    5 +-
 net/unix/diag.c           |   80 ++++++++++++----------------
 10 files changed, 193 insertions(+), 324 deletions(-)

-- 
1.7.7.6
