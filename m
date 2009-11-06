From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 6 Nov 2009 11:55:54 +1100
Message-ID: <20091106115554.44622e53.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	Torgny Johansson <torgny.johansson@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/usb/cdc_ether.c between commit
3a19d56c71bd3a08412d609d219ac8eec0819166 ("cdc_ether: additional Ericsson
MBM PID's to the whitelist") from the net-current tree and commit
e1e499eef2200c2a7120c9ebf297d48b195cf887 ("usbnet: Use wwan%d interface
name for mobile broadband devices") from the net tree.

Context changes.  I fixed it up (see below) and can carry it as
necessary.  This fix may not be completely correct ...

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/usb/cdc_ether.c
index 21e1ba1,71e65fc..0000000
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@@ -542,62 -550,22 +550,62 @@@ static const struct usb_device_id	produ
  	/* Ericsson F3607gw */
  	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1904, USB_CLASS_COMM,
  			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
- 	.driver_info = (unsigned long) &cdc_info,
+ 	.driver_info = (unsigned long) &mbm_info,
  }, {
 -	/* Ericsson F3307 */
 +	/* Ericsson F3607gw ver 2 */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1905, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
 +	/* Ericsson F3607gw ver 3 */
  	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1906, USB_CLASS_COMM,
  			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
- 	.driver_info = (unsigned long) &cdc_info,
+ 	.driver_info = (unsigned long) &mbm_info,
  }, {
 +	/* Ericsson F3307 */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x190a, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
 +	/* Ericsson F3307 ver 2 */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1909, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
 +	/* Ericsson C3607w */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1049, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
  	/* Toshiba F3507g */
  	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
  			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
- 	.driver_info = (unsigned long) &cdc_info,
+ 	.driver_info = (unsigned long) &mbm_info,
  }, {
 +	/* Toshiba F3607gw */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130c, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
 +	/* Toshiba F3607gw ver 2 */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x1311, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
  	/* Dell F3507g */
  	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8147, USB_CLASS_COMM,
  			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
- 	.driver_info = (unsigned long) &cdc_info,
+ 	.driver_info = (unsigned long) &mbm_info,
 +}, {
 +	/* Dell F3607gw */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8183, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
 +}, {
 +	/* Dell F3607gw ver 2 */
 +	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8184, USB_CLASS_COMM,
 +			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 +	.driver_info = (unsigned long) &cdc_info,
  },
  	{ },		// END
  };
