From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 3/3] tg3: make driver only data static
Date: Fri, 15 Oct 2004 13:50:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015135005.6bf68ee3@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several data structures should have been marked static because
the are local to this driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-10-15 12:57:56 -07:00
+++ b/drivers/net/tg3.c	2004-10-15 12:57:56 -07:00
@@ -224,8 +224,8 @@
 
 MODULE_DEVICE_TABLE(pci, tg3_pci_tbl);
 
-struct {
-	char string[ETH_GSTRING_LEN];
+static struct {
+	const char string[ETH_GSTRING_LEN];
 } ethtool_stats_keys[TG3_NUM_STATS] = {
 	{ "rx_octets" },
 	{ "rx_fragments" },
@@ -4504,7 +4504,7 @@
 	0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c, 0x00000000, 0x00000000,
 };
 
-u32 tg3TsoFwRodata[] = {
+static u32 tg3TsoFwRodata[] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x496e0000, 0x73746b6f,
 	0x66662a2a, 0x00000000, 0x53774576, 0x656e7430, 0x00000000, 0x00000000,
@@ -4512,7 +4512,7 @@
 	0x00000000,
 };
 
-u32 tg3TsoFwData[] = {
+static u32 tg3TsoFwData[] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x362e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
 	0x00000000,
@@ -4693,14 +4693,14 @@
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
+static u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x00000000, 0x00000000,
 	0x73746b6f, 0x66666c64, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
+static u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x322e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000,
 };
