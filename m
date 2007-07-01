From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.22-rc6] net/usb/cdc_ether minor sparse cleanup
Date: Sun, 1 Jul 2007 11:47:59 -0700
Message-ID: <200707011148.00019.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:22665 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755415AbXGASs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 14:48:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove an "sparse" warning about a shadowed variable name.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/cdc_ether.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- g26.orig/drivers/net/usb/cdc_ether.c	2007-07-01 11:40:37.000000000 -0700
+++ g26/drivers/net/usb/cdc_ether.c	2007-07-01 11:40:48.000000000 -0700
@@ -144,14 +144,14 @@ int usbnet_generic_cdc_bind(struct usbne
 			 * modem interface from an RNDIS non-modem.
 			 */
 			if (rndis) {
-				struct usb_cdc_acm_descriptor *d;
+				struct usb_cdc_acm_descriptor *acm;
 
-				d = (void *) buf;
-				if (d->bmCapabilities) {
+				acm = (void *) buf;
+				if (acm->bmCapabilities) {
 					dev_dbg(&intf->dev,
 						"ACM capabilities %02x, "
 						"not really RNDIS?\n",
-						d->bmCapabilities);
+						acm->bmCapabilities);
 					goto bad_desc;
 				}
 			}
