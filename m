From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH for kernel 3.4.x 0/1] net: neighbour: Add mcast_resolicit to configure the number of multicast resolicitations in PROBE state
Date: Tue, 24 Mar 2015 17:45:54 +0800
Message-ID: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<ulf.samuelsson@ericsson.com>,
	<hideaki.yoshifuji@miraclelinux.com>, <yoshfuji@linux-ipv6.org>,
	<Alexandre.Dietsch@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40227 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbbCXJpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 05:45:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is for the kernel 4.0. But kernel 3.4 needs this patch, too. So this patch is backported.
There are the following modifications:
 1. Because the mothod to set sysctl is different between kernel 3.4 and kernel 4.0, in this patch, the sysctl method is changed;
 2. Because the variables of mcast_resolicit is different, in this patch, the function neigh_max_probes is changed;
 3. Because there are so many modifications in this patch, so the author is changed to me;

Zhu Yanjun (1):
  net: neighbour: Add mcast_resolicit to configure the number of
    multicast resolicitations in PROBE state

 include/linux/neighbour.h |  1 +
 include/net/neighbour.h   |  1 +
 net/core/neighbour.c      | 20 +++++++++++++++++---
 3 files changed, 19 insertions(+), 3 deletions(-)

-- 
1.9.1
