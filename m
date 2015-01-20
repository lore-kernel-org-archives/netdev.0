From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 05/11] hso: fix small indentation error
Date: Tue, 20 Jan 2015 13:29:32 +0100
Message-ID: <1421756978-4093-6-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:48329 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbbATMaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 07:30:25 -0500
In-Reply-To: <1421756978-4093-5-git-send-email-olivier@sobrie.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply remove the useless extra tab.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a49ac2e..2f2343d 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2206,8 +2206,8 @@ static int hso_stop_serial_device(struct hso_device *hso_dev)
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
 		if (serial->rx_urb[i]) {
-				usb_kill_urb(serial->rx_urb[i]);
-				serial->rx_urb_filled[i] = 0;
+			usb_kill_urb(serial->rx_urb[i]);
+			serial->rx_urb_filled[i] = 0;
 		}
 	}
 	serial->curr_rx_urb_idx = 0;
-- 
2.2.0
