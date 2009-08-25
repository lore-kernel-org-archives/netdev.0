From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/9] s2io.c: Use const for strings
Date: Mon, 24 Aug 2009 20:29:40 -0700
Message-ID: <ae3194c10741ca46f510031718b70ea40e7a76ff.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1355 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341AbZHYDjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 23:39:04 -0400
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index bd6d713..07e95e9 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -125,7 +125,7 @@ static inline int is_s2io_card_up(const struct s2io_nic * sp)
 }
 
 /* Ethtool related variables and Macros. */
-static char s2io_gstrings[][ETH_GSTRING_LEN] = {
+static const char s2io_gstrings[][ETH_GSTRING_LEN] = {
 	"Register test\t(offline)",
 	"Eeprom test\t(offline)",
 	"Link test\t(online)",
@@ -133,7 +133,7 @@ static char s2io_gstrings[][ETH_GSTRING_LEN] = {
 	"BIST Test\t(offline)"
 };
 
-static char ethtool_xena_stats_keys[][ETH_GSTRING_LEN] = {
+static const char ethtool_xena_stats_keys[][ETH_GSTRING_LEN] = {
 	{"tmac_frms"},
 	{"tmac_data_octets"},
 	{"tmac_drop_frms"},
@@ -230,7 +230,7 @@ static char ethtool_xena_stats_keys[][ETH_GSTRING_LEN] = {
 	{"rxf_wr_cnt"}
 };
 
-static char ethtool_enhanced_stats_keys[][ETH_GSTRING_LEN] = {
+static const char ethtool_enhanced_stats_keys[][ETH_GSTRING_LEN] = {
 	{"rmac_ttl_1519_4095_frms"},
 	{"rmac_ttl_4096_8191_frms"},
 	{"rmac_ttl_8192_max_frms"},
@@ -249,7 +249,7 @@ static char ethtool_enhanced_stats_keys[][ETH_GSTRING_LEN] = {
 	{"link_fault_cnt"}
 };
 
-static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
+static const char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	{"\n DRIVER STATISTICS"},
 	{"single_bit_ecc_errs"},
 	{"double_bit_ecc_errs"},
-- 
1.6.3.1.10.g659a0.dirty

