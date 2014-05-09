From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] Add DRA7xx platform support in cpsw-phy-sel driver
Date: Fri, 9 May 2014 16:33:22 +0530
Message-ID: <1399633404-5818-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48886 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbaEILDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 07:03:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DRA7xx platform support to cpsw-phy-sel driver to select phy mode in
control driver and fixing the uninitialized dev by initializing to platform
device structure pointer.

Mugunthan V N (2):
  drivers: net: cpsw-phy-sel: add dra7xx support for phy sel
  drivers: net: cpsw-phy-sel: add am43xx platform support

 .../devicetree/bindings/net/cpsw-phy-sel.txt       |  4 +-
 drivers/net/ethernet/ti/cpsw-phy-sel.c             | 61 +++++++++++++++++++++-
 2 files changed, 63 insertions(+), 2 deletions(-)

-- 
1.9.2.459.g68773ac
