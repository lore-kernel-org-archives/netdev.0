From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 18 Aug 2015 12:35:16 +1000
Message-ID: <20150818123516.23d5120f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Ward <david.ward@ll.mit.edu>,
	Pieter Hollants <pieter@hollants.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/usb/qmi_wwan.c

between commit:

  a8079092c1bb ("net: qmi_wwan: add HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module")

from the net tree and commit:

  2070c48cf2b7 ("qmi_wwan: Add support for Dell Wireless 5809e 4G Modem")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/usb/qmi_wwan.c
index 64a60afbe50c,1f7a7cd97e50..000000000000
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@@ -785,7 -785,7 +785,8 @@@ static const struct usb_device_id produ
  	{QMI_FIXED_INTF(0x413c, 0x81a4, 8)},	/* Dell Wireless 5570e HSPA+ (42Mbps) Mobile Broadband Card */
  	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM) 4G LTE Mobile Broadband Card */
  	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) 4G LTE Mobile Broadband Card */
+ 	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) 4G LTE Mobile Broadband Card */
 +	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module */
  	{QMI_FIXED_INTF(0x03f0, 0x581d, 4)},	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
  
  	/* 4. Gobi 1000 devices */
