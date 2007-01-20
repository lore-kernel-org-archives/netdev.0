From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] PHY: Export phy ethtool helpers
Date: Sat, 20 Jan 2007 16:38:26 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0701201637290.17538@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53166 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbXATWih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jan 2007 17:38:37 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to export phy_ethtool_gset and phy_ethtool_sset to allow drivers that
use these functions to be built as modules.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

---
commit 7fff6ffb83f2543299df3ed8815976440abdd576
tree 0eea7a64a684a3d3970cec9a8c9c65ee2839ebfc
parent a8b3485287731978899ced11f24628c927890e78
author Kumar Gala <galak@kernel.crashing.org> Sat, 20 Jan 2007 16:28:13 -0600
committer Kumar Gala <galak@kernel.crashing.org> Sat, 20 Jan 2007 16:28:13 -0600

  drivers/net/phy/phy.c |    2 ++
  1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e175f39..868400d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -286,6 +286,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)

  	return 0;
  }
+EXPORT_SYMBOL(phy_ethtool_sset);

  int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
  {
@@ -302,6 +303,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)

  	return 0;
  }
+EXPORT_SYMBOL(phy_ethtool_gset);


  /* Note that this function is currently incompatible with the
