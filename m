From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Wed, 15 Jan 2014 22:20:51 +0800
Message-ID: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Cc: therbert@google.com, edumazet@google.com, davem@davemloft.net,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34637 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbaAOOVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:21:07 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 15 Jan 2014 07:21:06 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0626E19D8046
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:20:55 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0FCIfZr9961748
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 13:18:41 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0FEL3JT007043
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:21:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

HI, folks

The patchset is trying to integrate aRFS support to virtio_net. In this case,
aRFS will be used to select the RX queue. To make sure that it's going ahead
in the correct direction, although it is still one RFC and isn't tested, it's
post out ASAP. Any comment are appreciated, thanks.

If anyone is interested in playing with it, you can get this patchset from my
dev git on github:
  git://github.com/wuzhy/kernel.git virtnet_rfs

Zhi Yong Wu (3):
  virtio_pci: Introduce one new config api vp_get_vq_irq()
  virtio_net: Introduce one dummy function virtnet_filter_rfs()
  virtio-net: Add accelerated RFS support

 drivers/net/virtio_net.c      |   67 ++++++++++++++++++++++++++++++++++++++++-
 drivers/virtio/virtio_pci.c   |   11 +++++++
 include/linux/virtio_config.h |   12 +++++++
 3 files changed, 89 insertions(+), 1 deletions(-)

-- 
1.7.6.5
