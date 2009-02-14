From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 40/43] drivers/net/wireless/ath9k: fix sparse warnings: Should
	it be static?
Date: Sat, 14 Feb 2009 22:49:48 +0100
Message-ID: <20090214214935.24377.69824.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:51560 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbZBNVtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:49:55 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Make symbols static.

Fix this sparse warnings:
  drivers/net/wireless/ath9k/eeprom.c:1343:5: warning: symbol 'ath9k_hw_4k_get_spur_channel' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:1372:19: warning: symbol 'eep_4k_ops' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2649:5: warning: symbol 'ath9k_hw_def_get_spur_channel' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2678:19: warning: symbol 'eep_def_ops' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/ath9k/eeprom.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath9k/eeprom.c b/drivers/net/wireless/ath9k/eeprom.c
index c0359ad..b55e992 100644
--- a/drivers/net/wireless/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath9k/eeprom.c
@@ -1340,7 +1340,7 @@ static u8 ath9k_hw_4k_get_num_ant_config(struct ath_hw *ah,
 	return 1;
 }
 
-u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
+static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 {
 #define EEP_MAP4K_SPURCHAN \
 	(ah->eeprom.map4k.modalHeader.spurChans[i].spurChan)
@@ -1369,7 +1369,7 @@ u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 #undef EEP_MAP4K_SPURCHAN
 }
 
-struct eeprom_ops eep_4k_ops = {
+static struct eeprom_ops eep_4k_ops = {
 	.check_eeprom		= ath9k_hw_4k_check_eeprom,
 	.get_eeprom		= ath9k_hw_4k_get_eeprom,
 	.fill_eeprom		= ath9k_hw_4k_fill_eeprom,
@@ -2646,7 +2646,7 @@ static u16 ath9k_hw_def_get_eeprom_antenna_cfg(struct ath_hw *ah,
 	return pModal->antCtrlCommon & 0xFFFF;
 }
 
-u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
+static u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 {
 #define EEP_DEF_SPURCHAN \
 	(ah->eeprom.def.modalHeader[is2GHz].spurChans[i].spurChan)
@@ -2675,7 +2675,7 @@ u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 #undef EEP_DEF_SPURCHAN
 }
 
-struct eeprom_ops eep_def_ops = {
+static struct eeprom_ops eep_def_ops = {
 	.check_eeprom		= ath9k_hw_def_check_eeprom,
 	.get_eeprom		= ath9k_hw_def_get_eeprom,
 	.fill_eeprom		= ath9k_hw_def_fill_eeprom,

