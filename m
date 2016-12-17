From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn/gigaset: use designated initializers
Date: Fri, 16 Dec 2016 16:58:06 -0800
Message-ID: <20161217005806.GA140074@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Tilman Schmidt <tilman@imap.cc>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/gigaset/bas-gigaset.c | 32 ++++++++++++++++----------------
 drivers/isdn/gigaset/ser-gigaset.c | 32 ++++++++++++++++----------------
 drivers/isdn/gigaset/usb-gigaset.c | 32 ++++++++++++++++----------------
 3 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index aecec6d32463..11e13c56126f 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2565,22 +2565,22 @@ static int gigaset_post_reset(struct usb_interface *intf)
 
 
 static const struct gigaset_ops gigops = {
-	gigaset_write_cmd,
-	gigaset_write_room,
-	gigaset_chars_in_buffer,
-	gigaset_brkchars,
-	gigaset_init_bchannel,
-	gigaset_close_bchannel,
-	gigaset_initbcshw,
-	gigaset_freebcshw,
-	gigaset_reinitbcshw,
-	gigaset_initcshw,
-	gigaset_freecshw,
-	gigaset_set_modem_ctrl,
-	gigaset_baud_rate,
-	gigaset_set_line_ctrl,
-	gigaset_isoc_send_skb,
-	gigaset_isoc_input,
+	.write_cmd = gigaset_write_cmd,
+	.write_room = gigaset_write_room,
+	.chars_in_buffer = gigaset_chars_in_buffer,
+	.brkchars = gigaset_brkchars,
+	.init_bchannel = gigaset_init_bchannel,
+	.close_bchannel = gigaset_close_bchannel,
+	.initbcshw = gigaset_initbcshw,
+	.freebcshw = gigaset_freebcshw,
+	.reinitbcshw = gigaset_reinitbcshw,
+	.initcshw = gigaset_initcshw,
+	.freecshw = gigaset_freecshw,
+	.set_modem_ctrl = gigaset_set_modem_ctrl,
+	.baud_rate = gigaset_baud_rate,
+	.set_line_ctrl = gigaset_set_line_ctrl,
+	.send_skb = gigaset_isoc_send_skb,
+	.handle_input = gigaset_isoc_input,
 };
 
 /* bas_gigaset_init
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index b90776ef56ec..ab0b63a4d045 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -445,22 +445,22 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 }
 
 static const struct gigaset_ops ops = {
-	gigaset_write_cmd,
-	gigaset_write_room,
-	gigaset_chars_in_buffer,
-	gigaset_brkchars,
-	gigaset_init_bchannel,
-	gigaset_close_bchannel,
-	gigaset_initbcshw,
-	gigaset_freebcshw,
-	gigaset_reinitbcshw,
-	gigaset_initcshw,
-	gigaset_freecshw,
-	gigaset_set_modem_ctrl,
-	gigaset_baud_rate,
-	gigaset_set_line_ctrl,
-	gigaset_m10x_send_skb,	/* asyncdata.c */
-	gigaset_m10x_input,	/* asyncdata.c */
+	.write_cmd = gigaset_write_cmd,
+	.write_room = gigaset_write_room,
+	.chars_in_buffer = gigaset_chars_in_buffer,
+	.brkchars = gigaset_brkchars,
+	.init_bchannel = gigaset_init_bchannel,
+	.close_bchannel = gigaset_close_bchannel,
+	.initbcshw = gigaset_initbcshw,
+	.freebcshw = gigaset_freebcshw,
+	.reinitbcshw = gigaset_reinitbcshw,
+	.initcshw = gigaset_initcshw,
+	.freecshw = gigaset_freecshw,
+	.set_modem_ctrl = gigaset_set_modem_ctrl,
+	.baud_rate = gigaset_baud_rate,
+	.set_line_ctrl = gigaset_set_line_ctrl,
+	.send_skb = gigaset_m10x_send_skb,	/* asyncdata.c */
+	.handle_input = gigaset_m10x_input,	/* asyncdata.c */
 };
 
 
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 5f306e2eece5..eade36dafa34 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -862,22 +862,22 @@ static int gigaset_pre_reset(struct usb_interface *intf)
 }
 
 static const struct gigaset_ops ops = {
-	gigaset_write_cmd,
-	gigaset_write_room,
-	gigaset_chars_in_buffer,
-	gigaset_brkchars,
-	gigaset_init_bchannel,
-	gigaset_close_bchannel,
-	gigaset_initbcshw,
-	gigaset_freebcshw,
-	gigaset_reinitbcshw,
-	gigaset_initcshw,
-	gigaset_freecshw,
-	gigaset_set_modem_ctrl,
-	gigaset_baud_rate,
-	gigaset_set_line_ctrl,
-	gigaset_m10x_send_skb,
-	gigaset_m10x_input,
+	.write_cmd = gigaset_write_cmd,
+	.write_room = gigaset_write_room,
+	.chars_in_buffer = gigaset_chars_in_buffer,
+	.brkchars = gigaset_brkchars,
+	.init_bchannel = gigaset_init_bchannel,
+	.close_bchannel = gigaset_close_bchannel,
+	.initbcshw = gigaset_initbcshw,
+	.freebcshw = gigaset_freebcshw,
+	.reinitbcshw = gigaset_reinitbcshw,
+	.initcshw = gigaset_initcshw,
+	.freecshw = gigaset_freecshw,
+	.set_modem_ctrl = gigaset_set_modem_ctrl,
+	.baud_rate = gigaset_baud_rate,
+	.set_line_ctrl = gigaset_set_line_ctrl,
+	.send_skb = gigaset_m10x_send_skb,
+	.handle_input = gigaset_m10x_input,
 };
 
 /*
-- 
2.7.4


-- 
Kees Cook
Nexus Security
