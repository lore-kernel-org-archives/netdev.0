From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/3] be2net: patch set
Date: Thu, 26 Mar 2015 03:05:07 -0400
Message-ID: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:33044 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbbCZHBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:01:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, this patch set includes 2 feature additions to the be2net driver:

Patch 1 sets up cpu affinity hints for be2net irqs using the
cpumask_set_cpu_local_first() API that first picks the near numa cores
and when they are exhausted, selects the far numa cores.

Patch 2 setups up xps queue mapping for be2net's TXQs to avoid,
by default, TX lock contention.

Patch 3 just bumps up the driver version.

Pls consider applying this patch set to the net-next queue. Thanks!

Padmanabh Ratnakar (1):
  be2net: assign CPU affinity hints to be2net IRQs

Sathya Perla (2):
  be2net: setup xps queue mapping
  be2net: bump up the driver version to 10.6.0.1

 drivers/net/ethernet/emulex/benet/be.h      |  4 +++-
 drivers/net/ethernet/emulex/benet/be_main.c | 27 +++++++++++++++++++++------
 2 files changed, 24 insertions(+), 7 deletions(-)

-- 
2.2.0
