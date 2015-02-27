From: Yannick Guerrini <yguerrini@tomshardware.fr>
Subject: [PATCH] netxen_nic: Fix trivial typos in comments
Date: Fri, 27 Feb 2015 18:38:46 +0100
Message-ID: <1425058726-8908-1-git-send-email-yguerrini@tomshardware.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sony.chacko@qlogic.com>, <rajesh.borundia@qlogic.com>,
	<trivial@kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Yannick Guerrini <yguerrini@tomshardware.fr>
To: <manish.chopra@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change 'mutliple' to 'multiple'
Change 'Firmare' to 'Firmware'

Signed-off-by: Yannick Guerrini <yguerrini@tomshardware.fr>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 6e426ae..0a5e204 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -354,7 +354,7 @@ struct cmd_desc_type0 {
 
 } __attribute__ ((aligned(64)));
 
-/* Note: sizeof(rcv_desc) should always be a mutliple of 2 */
+/* Note: sizeof(rcv_desc) should always be a multiple of 2 */
 struct rcv_desc {
 	__le16 reference_handle;
 	__le16 reserved;
@@ -499,7 +499,7 @@ struct uni_data_desc{
 #define NETXEN_IMAGE_START	0x43000	/* compressed image */
 #define NETXEN_SECONDARY_START	0x200000	/* backup images */
 #define NETXEN_PXE_START	0x3E0000	/* PXE boot rom */
-#define NETXEN_USER_START	0x3E8000	/* Firmare info */
+#define NETXEN_USER_START	0x3E8000	/* Firmware info */
 #define NETXEN_FIXED_START	0x3F0000	/* backup of crbinit */
 #define NETXEN_USER_START_OLD	NETXEN_PXE_START /* very old flash */
 
-- 
1.9.5.msysgit.0
