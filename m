From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 0/3] Add DRA7xx and AM43xx platform support in cpsw-phy-sel driver
Date: Fri, 9 May 2014 19:07:32 +0530
Message-ID: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57276 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271AbaEINhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 09:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DRA7xx and AM43xx platform support to cpsw-phy-sel driver to select
phy mode in control driver and fixing the uninitialized dev by initializing
to platform device structure pointer.

Changes from Initial version
* Added back the missing patch (1/3)

Mugunthan V N (3):
  drivers: net: cpsw-phy-sel: initialize priv->dev
  drivers: net: cpsw-phy-sel: add dra7xx support for phy sel
  drivers: net: cpsw-phy-sel: add am43xx platform support

 .../devicetree/bindings/net/cpsw-phy-sel.txt       |  4 +-
 drivers/net/ethernet/ti/cpsw-phy-sel.c             | 62 +++++++++++++++++++++-
 2 files changed, 64 insertions(+), 2 deletions(-)

-- 
1.9.2.459.g68773ac
