From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Wed, 20 Sep 2017 12:49:01 +0200
Message-ID: <1505904543-10004-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56968 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751497AbdITKtL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 06:49:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EBD0B20A531
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 12:49:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DBA79B503F
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 12:49:09 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two Netfilter fixes for your net tree,
they are:

1) Fix NAt compilation with UP, from Geert Uytterhoeven.

2) Fix incorrect number of entries when dumping a set, from
   Vishwanath Pai.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e:

  Linux 4.14-rc1 (2017-09-16 15:47:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 7f4f7dd4417d9efd038b14d39c70170db2e0baa0:

  netfilter: ipset: ipset list may return wrong member count for set with timeout (2017-09-18 17:35:32 +0200)

----------------------------------------------------------------
Geert Uytterhoeven (1):
      netfilter: nat: Do not use ARRAY_SIZE() on spinlocks to fix zero div

Vishwanath Pai (1):
      netfilter: ipset: ipset list may return wrong member count for set with timeout

 net/netfilter/ipset/ip_set_hash_gen.h | 14 +++++++++++++-
 net/netfilter/nf_nat_core.c           | 12 ++++++------
 2 files changed, 19 insertions(+), 7 deletions(-)
