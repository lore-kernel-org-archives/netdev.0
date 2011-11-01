From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 19/21] Declare static variables const as appropriate
Date: Tue, 1 Nov 2011 23:22:19 +0000
Message-ID: <1320189739.2758.50.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38706 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab1KAXWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:22:22 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    4 ++--
 rxclass.c |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 13fb0ef..8e757e9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -104,7 +104,7 @@ static int do_permaddr(struct cmd_context *ctx);
 static int do_getfwdump(struct cmd_context *ctx);
 static int do_setfwdump(struct cmd_context *ctx);
 
-static struct option {
+static const struct option {
 	const char *opts;
 	int want_device;
 	int (*func)(struct cmd_context *);
@@ -965,7 +965,7 @@ static char *unparse_rxfhashopts(u64 opts)
 	return buf;
 }
 
-static struct {
+static const struct {
 	const char *name;
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
diff --git a/rxclass.c b/rxclass.c
index 3b23a33..1980d0e 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -533,7 +533,7 @@ struct rule_opts {
 	int		moffset;
 };
 
-static struct rule_opts rule_nfc_tcp_ip4[] = {
+static const struct rule_opts rule_nfc_tcp_ip4[] = {
 	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.ip4src),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.ip4src) },
@@ -564,7 +564,7 @@ static struct rule_opts rule_nfc_tcp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
 };
 
-static struct rule_opts rule_nfc_esp_ip4[] = {
+static const struct rule_opts rule_nfc_esp_ip4[] = {
 	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.ip4src),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.ip4src) },
@@ -592,7 +592,7 @@ static struct rule_opts rule_nfc_esp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
 };
 
-static struct rule_opts rule_nfc_usr_ip4[] = {
+static const struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.ip4src),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.ip4src) },
@@ -632,7 +632,7 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
 };
 
-static struct rule_opts rule_nfc_ether[] = {
+static const struct rule_opts rule_nfc_ether[] = {
 	{ "src", OPT_MAC, NFC_FLAG_SADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_source),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_source) },
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
