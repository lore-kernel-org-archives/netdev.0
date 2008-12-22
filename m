From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 09/27] drivers/net/e1000e: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:16:13 +0100
Message-ID: <20081222191613.11807.47997.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.184]:23983 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214AbYLVTW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:22:56 -0500
Received: by mu-out-0910.google.com with SMTP id g7so945564muf.1
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2008 11:22:54 -0800 (PST)
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/e1000e/es2lan.c:1265:5: warning: symbol 'e1000_read_kmrn_reg_80003es2lan' was not declared. Should it be static?
  drivers/net/e1000e/es2lan.c:1298:5: warning: symbol 'e1000_write_kmrn_reg_80003es2lan' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/e1000e/es2lan.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index db51114..8964838 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1262,7 +1262,8 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
  *  using the kumeran interface.  The information retrieved is stored in data.
  *  Release the semaphore before exiting.
  **/
-s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset, u16 *data)
+static s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
+					   u16 *data)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val = 0;
@@ -1295,7 +1296,8 @@ s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset, u16 *data)
  *  at the offset using the kumeran interface.  Release semaphore
  *  before exiting.
  **/
-s32 e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset, u16 data)
+static s32 e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
+					    u16 data)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val = 0;

