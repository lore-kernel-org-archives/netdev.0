From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 3.4.y 0/3] netprio_cgroup: a few patches for stable tree
Date: Sat, 26 Jan 2013 12:40:47 +0800
Message-ID: <51035E4F.6030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Gao feng <gaofeng@cn.fujitsu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38699 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab3AZElB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 23:41:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Could you queue those patches for 3.4 stable tree?

The first 2 bugs were fixed in 3.5, and the last one was fixed in 3.6.

I've re-generated the last 2 patches, as the upstream commits can't be
applied to 3.4 cleanly.

Gao feng (2):
      cgroup: fix panic in netprio_cgroup
      net: cgroup: fix access the unallocated memory in netprio cgroup

John Fastabend (1):
      net: netprio: fix cgrp create and write priomap race

 net/core/netprio_cgroup.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 57 insertions(+), 21 deletions(-)
