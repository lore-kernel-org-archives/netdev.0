From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] hso: Fix unused variable warning
Date: Mon, 15 Nov 2010 17:30:42 +0000
Message-ID: <20101115173038.6846.72062.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:47957 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933237Ab0KORup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:50:45 -0500
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.4/8.14.1) with ESMTP id oAFHPUcu009816
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 17:25:36 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Fallout from the TIOCGICOUNT work

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/usb/hso.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index b154a94..be8cc2a 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1745,7 +1745,6 @@ static int hso_serial_ioctl(struct tty_struct *tty, struct file *file,
 			    unsigned int cmd, unsigned long arg)
 {
 	struct hso_serial *serial =  get_serial_by_tty(tty);
-	void __user *uarg = (void __user *)arg;
 	int ret = 0;
 	D4("IOCTL cmd: %d, arg: %ld", cmd, arg);
 

