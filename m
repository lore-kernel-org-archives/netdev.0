From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v5 0/4] virtio_net: Add MAC and VLAN filtering
Date: Wed, 04 Feb 2009 12:02:29 -0700
Message-ID: <20090204190229.2512.93552.stgit@debian.lart>
References: <20090203.150636.175381174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:17872 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762342AbZBDTF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 14:05:26 -0500
In-Reply-To: <20090203.150636.175381174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds infrastructure for a new control virtqueue and
makes use of it to support set_rx_mode, unicast and multicast address
lists, and supporting a hypervisor based VLAN filter.  The goal is to
make the virtio-net device support more of the features of a physical
NIC and allow the hypervisor to discard packets we don't want.  These
patches are intended for 2.6.30.

This version is just a rebase to current net-next-2.6.git.  I'll send
Rusty an update to the patch in his queue that led to the patch
conflict, this series doesn't depend on it.

Alex

---

Alex Williamson (4):
      virtio_net: Add support for VLAN filtering in the hypervisor
      virtio_net: Add a MAC filter table
      virtio_net: Add a set_rx_mode interface
      virtio_net: Add a virtqueue for outbound control commands


 drivers/net/virtio_net.c   |  168 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   66 +++++++++++++++++
 2 files changed, 231 insertions(+), 3 deletions(-)

-- 
Alex Williamson
