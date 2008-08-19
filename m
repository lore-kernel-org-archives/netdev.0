From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1 2.6.26-rc3] s2io: Fix code indentation
Date: Tue, 19 Aug 2008 11:18:01 -0300
Message-ID: <48AAD619.4000406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw1.br.ibm.com ([32.104.18.24]:57702 "EHLO igw1.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbYHSOka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 10:40:30 -0400
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw1.br.ibm.com (Postfix) with ESMTP id E26AB32C0B4
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 11:11:13 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m7JEIT7u2699320
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 11:18:34 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7JEIM04001637
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 11:18:22 -0300
Received: from [9.8.4.139] ([9.8.4.139])
	by d24av01.br.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m7JEILca000784
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 11:18:22 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A patch that just fixes the s2io source code indentation, replacing spaces 
by tabs.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..f25190a 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -517,9 +517,9 @@ static struct pci_device_id s2io_tbl[] __devinitdata = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_WIN,
-         PCI_ANY_ID, PCI_ANY_ID},
-        {PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
-         PCI_ANY_ID, PCI_ANY_ID},
+	PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
+	PCI_ANY_ID, PCI_ANY_ID},
 	{0,}
 };
 
@@ -532,11 +532,11 @@ static struct pci_error_handlers s2io_err_handler = {
 };
 
 static struct pci_driver s2io_driver = {
-      .name = "S2IO",
-      .id_table = s2io_tbl,
-      .probe = s2io_init_nic,
-      .remove = __devexit_p(s2io_rem_nic),
-      .err_handler = &s2io_err_handler,
+	.name = "S2IO",
+	.id_table = s2io_tbl,
+	.probe = s2io_init_nic,
+	.remove = __devexit_p(s2io_rem_nic),
+	.err_handler = &s2io_err_handler,
 };
 
 /* A simplifier macro used both by init and free shared_mem Fns(). */
@@ -6320,19 +6320,19 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->tmac_bcst_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_bcst_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_ttl_octets);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_ucst_frms);
+		(u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_ttl_octets);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
-                le32_to_cpu(stat_info->tmac_nucst_frms);
+		(u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_ucst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_any_err_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_any_err_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_vld_ip_oflow) << 32 |
@@ -6368,23 +6368,23 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_unsup_ctrl_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_ttl_octets);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow)
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow)
 		<< 32 | le32_to_cpu(stat_info->rmac_accepted_ucst_frms);
 	tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
-                 << 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
+		(u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
+		<< 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_discarded_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_discarded_frms);
-        tmp_stats[i++] =
-                (u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
-                 << 32 | le32_to_cpu(stat_info->rmac_drop_events);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
+		<< 32 | le32_to_cpu(stat_info->rmac_drop_events);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_usized_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_usized_frms);
@@ -6398,11 +6398,11 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->rmac_jabber_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_jabber_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_64_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_ip);
@@ -6422,22 +6422,22 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 		(u64)le32_to_cpu(stat_info->rmac_err_drp_udp_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_err_drp_udp);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_err_sym);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
-        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
+	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_pause_cnt_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_pause_cnt);
