From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/7] ixgbe: Remove unused emulation MAC storage
	from the per VF data structure.
Date: Sat, 23 Jan 2010 00:46:02 -0800
Message-ID: <20100123084601.9865.89876.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:54755
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753986Ab0AWIqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:46:20 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

This data storage for SW emulated MAC addresses is unlikely to ever be used
so pull it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ed73585..e3909d3 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -110,7 +110,6 @@ struct vf_data_storage {
 	u16 num_vf_mc_hashes;
 	u16 default_vf_vlan_id;
 	u16 vlans_enabled;
-	unsigned char em_mac_addresses[MAX_EMULATION_MAC_ADDRS * ETH_ALEN];
 	bool clear_to_send;
 	int rar;
 };

