From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/5] vxlan fixes
Date: Thu, 17 Sep 2015 16:11:09 +0200
Message-ID: <cover.1442498316.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbbIQOLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:23 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 6722F8E6EA
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 14:11:23 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-25.brq.redhat.com [10.40.204.25])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t8HEBMd5023833
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 10:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes various issues with vxlan related to IPv6.

Jiri Benc (5):
  vxlan: set needed headroom correctly
  vxlan: reject IPv6 addresses if IPv6 is not configured
  qlcnic: track vxlan port count
  be2net: allow offloading with the same port for IPv4 and IPv6
  bnx2x: track vxlan port count

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 14 ++++++++++++--
 drivers/net/ethernet/emulex/benet/be.h           |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c      | 10 ++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 18 +++++++++++++-----
 drivers/net/vxlan.c                              | 15 +++++++++------
 7 files changed, 47 insertions(+), 13 deletions(-)

-- 
1.8.3.1
