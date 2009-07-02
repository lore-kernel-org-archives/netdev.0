From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/4] ixgbe: Not allow 8259x unsupported wol options
	change from ethtool
Date: Thu, 02 Jul 2009 15:51:10 -0700
Message-ID: <20090702225110.22746.42383.stgit@localhost.localdomain>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:33689 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753176AbZGBWvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:51:23 -0400
In-Reply-To: <20090702225012.22746.57218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Wake-on-lan is currently only supported by 82599 KX4 devices, in all
other cases return a proper value from ixgbe_wol_exclusion function call.
Otherwise from ethtool we will be able to change wol options of
unsupported 8259x devices.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0f7b6a3..2a97800 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1830,7 +1830,6 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 		break;
 	default:
 		wol->supported = 0;
-		retval = 0;
 	}
 
 	return retval;

