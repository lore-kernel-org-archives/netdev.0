From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] sis190: fix compile error section type conflict
Date: Sat, 02 Feb 2008 13:27:27 +0800
Message-ID: <47A3FF3F.1040908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54297 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759793AbYBBF2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 00:28:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the following compile error:

drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
make[2]: *** [drivers/net/sis190.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

---
 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..e48e4ad 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
-- 
1.5.4.rc3


