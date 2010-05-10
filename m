From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 03/64] Bluetooth: Fix wrong packet type count increment
Date: Mon, 10 May 2010 11:36:53 +0200
Message-ID: <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53431 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556Ab0EJJii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:38 -0400
In-Reply-To: <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_vhci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index bb0aefd..3aa7b2a 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -157,7 +157,7 @@ static inline ssize_t vhci_put_user(struct vhci_data *data,
 		break;
 
 	case HCI_SCODATA_PKT:
-		data->hdev->stat.cmd_tx++;
+		data->hdev->stat.sco_tx++;
 		break;
 	};
 
-- 
1.6.6.1

