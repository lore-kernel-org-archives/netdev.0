From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 05/11] hso: fix small indentation error
Date: Fri, 30 Jan 2015 13:21:57 +0100
Message-ID: <1422620523-15021-6-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-1-git-send-email-olivier@sobrie.be>
 <1422620523-15021-2-git-send-email-olivier@sobrie.be>
 <1422620523-15021-3-git-send-email-olivier@sobrie.be>
 <1422620523-15021-4-git-send-email-olivier@sobrie.be>
 <1422620523-15021-5-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422620523-15021-5-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
