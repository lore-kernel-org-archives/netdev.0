From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/8][BNX2]: Add S/G jumbo RX support.
Date: Wed, 12 Dec 2007 10:57:59 -0800
Message-ID: <1197485879.16386.25.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3035 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbXLLSNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add S/G jumbo RX support.

David, 8 patches will follow to implement S/G for jumbo RX packets.
Please review for 2.6.25.  Thanks.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c     |  510 +++-
 drivers/net/bnx2.h     |   43 +-
 drivers/net/bnx2_fw.h  | 7034 +++++++++++++++++++++++++---------------
 drivers/net/bnx2_fw2.h | 8416 +++++++++++++++++++++++++-----------------------
 4 files changed, 9301 insertions(+), 6702 deletions(-)

---
[PATCH 1/8][BNX2]: Add ring constants.
[PATCH 2/8][BNX2]: Restructure RX fast path handling.
[PATCH 3/8][BNX2]: Restructure RX ring init. code.
[PATCH 4/8 gzipped][BNX2]: Update firmware to support S/G RX buffers.
[PATCH 5/8][BNX2]: Add init. code to handle RX pages.
[PATCH 6/8][BNX2]: Add fast path code to handle RX pages.
[PATCH 7/8][BNX2]: Enable S/G for jumbo RX.
[PATCH 8/8][BNX2]: Update version to 1.6.9.


