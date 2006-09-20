From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r8169-20060920-00' tag
Date: Wed, 20 Sep 2006 21:23:32 +0200
Message-ID: <20060920192332.GA10396@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Matt Bockol <mbockol@carleton.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37835 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932305AbWITTZa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 15:25:30 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'r8169-20060920-00' in repository
 
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

to get the change below.

Note:
Since something went wrong last time I submitted a pull request, here
goes the trace from the start of the branch

$ git rev-list $(git merge-base v2.6.18 r8169-20060920-00)..
d81bf551103cc3bc9e4f7ddf337511d6da0d088f
b39fe41f481d20c201012e4483e76c203802dda7 (<- r8169-20060912-00)
d2eed8cff9a1a5d7e12ec9ddf71432c466b104d0
5f787a1aca3705bdc6adbda36f8d6446380e85a6
64e4bfb40c9d07a48c1c7e5b8556e92e7cd7406a
5b0384f4fd079c24b976ee333e6d1f0c95cf14de
b518fa8eac2d0ac497c0fdb27e4cec68d0249bb7
188f4af04618b32b8ec7c630a3f18201c81ce70c
bcf0bf90cd9e9242b66e0563b6a8c8db2e4c262c
4ff96fa67379c31ced69f193c7ffba17051f38e8
623a1593c84afb86b2f496a56fb4ec37f82b5c78
9dccf61112e6755f4e6f154c1794bab3c509bc71
a2b98a697fa4e7564f78905b83db122824916cf9

Shortlog
--------
 
Francois Romieu :
    r8169: the MMIO region of the 8167 stands behin BAR#1
     
Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 805562b..93cd1f4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -210,7 +210,7 @@ static const struct {
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_1 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },

-- 
Ueimor
