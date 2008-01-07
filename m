From: "Russell Dill" <russd@asu.edu>
Subject: [PATCH] [NET] kaweth was forgotten in msec switchover of usb_start_wait_urb
Date: Mon, 7 Jan 2008 16:20:20 -0700
Message-ID: <134b1d6c0801071520h9932537ke0b5daeaabab289b@mail.gmail.com>
Reply-To: Russ.Dill@asu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael Zappe" <zapman@interlan.net>,
	"Stephane Alnet" <stephane@u-picardie.fr>,
	"Brad Hards" <bhards@bigpond.net.au>,
	"Oliver Neukum" <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from epo-ps.asu.edu ([129.219.187.8]:57312 "EHLO epo-ps.asu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702AbYAGXu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 18:50:26 -0500
Received: from fg-out-1718.google.com (fg-out-1718.google.com [72.14.220.154])
	by epo-ps.asu.edu (Switch-3.3.0/Switch-3.3.0/asu-postoffice-prod) with ESMTP id m07NKKqw015240
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 16:20:20 -0700
Received: by fg-out-1718.google.com with SMTP id 22so4884670fge.24
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2008 15:20:20 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in 2.6.12-pre, usb_start_wait_urb was switched over to take
milliseconds instead of jiffies. kaweth.c was never updated to match.

Signed-off-by: Russ Dill <Russ.Dill@asu.edu>
---
 drivers/net/usb/kaweth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 58a53a6..569ad8b 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -70,7 +70,7 @@
 #define KAWETH_TX_TIMEOUT		(5 * HZ)
 #define KAWETH_SCRATCH_SIZE		32
 #define KAWETH_FIRMWARE_BUF_SIZE	4096
-#define KAWETH_CONTROL_TIMEOUT		(30 * HZ)
+#define KAWETH_CONTROL_TIMEOUT		(30000)

 #define KAWETH_STATUS_BROKEN		0x0000001
 #define KAWETH_STATUS_CLOSING		0x0000002
--
1.5.3.4
