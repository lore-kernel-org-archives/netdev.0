From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] bonding: add slave netlink and sysfs support
Date: Wed, 15 Jan 2014 21:54:27 -0800
Message-ID: <20140116054900.32220.57848.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40836 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbaAPFyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 00:54:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds bonding slave netlink and sysfs interfaces.
Slave interfaces get a new IFLA_SLAVE set of netlink attributes, along
with RTM_NEWLINK notification when slave's active status changes.  The
sysfs interface adds read-only nodes for slave attributes under a /slave
dir, simliar to how bond interfaces get a /bonding dir for bonding
attributes.

---

Scott Feldman (2):
      bonding: add sysfs /slave dir for bond slave devices.
      bonding: add netlink attributes to slave link dev


 drivers/net/bonding/Makefile           |    2 
 drivers/net/bonding/bond_main.c        |   28 ++++++
 drivers/net/bonding/bond_netlink.c     |   36 ++++++++
 drivers/net/bonding/bond_procfs.c      |   12 ---
 drivers/net/bonding/bond_sysfs_slave.c |  142 ++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h          |   15 +++
 include/linux/netdevice.h              |    5 +
 include/uapi/linux/if_link.h           |   13 +++
 net/core/rtnetlink.c                   |   54 ++++++++++++
 9 files changed, 292 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/bonding/bond_sysfs_slave.c

-- 
Signature
