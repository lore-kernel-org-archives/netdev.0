From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC iproute v1 0/4] afnetns: add support for afnetns
Date: Mon, 13 Mar 2017 00:01:34 +0100
Message-ID: <20170312230138.5096-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:32913 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935422AbdCLXBn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:43 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 37A9520682
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:42 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 391A7240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:40 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for afnetns to iproute.

For more information on afnetns please look at the kernel patchset.

Patches for util-linux commands, namely nsenter and unshare, is
available here: <https://github.com/hannes/util-linux/tree/afnetns>

Hannes Frederic Sowa (4):
  afnetns: add iproute bits for afnetns
  afnetns: support for ipv4/v6 address management
  afnetns: introduce lib/afnetns.c and a name cache
  afnetns: only show afnetns when show_details

 include/afnetns.h       |   6 ++
 include/libnetlink.h    |   7 ++
 include/linux/if_addr.h |   2 +
 include/namespace.h     |   4 +
 include/utils.h         |   1 +
 ip/Makefile             |   2 +-
 ip/ip.c                 |   5 +-
 ip/ip_common.h          |   1 +
 ip/ipaddress.c          |  38 ++++++++
 ip/ipafnetns.c          | 216 +++++++++++++++++++++++++++++++++++++++++++++
 lib/Makefile            |   2 +-
 lib/afnetns.c           | 226 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/utils.c             |  36 ++++++++
 13 files changed, 542 insertions(+), 4 deletions(-)
 create mode 100644 include/afnetns.h
 create mode 100644 ip/ipafnetns.c
 create mode 100644 lib/afnetns.c

-- 
2.9.3
