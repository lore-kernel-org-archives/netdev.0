From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make myri10ge_get_firmware_capabilities() static
Date: Tue, 20 May 2008 00:53:00 +0300
Message-ID: <20080519215300.GC17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brice Goglin <brice@myri.com>, Andrew Gallatin <gallatin@myri.com>,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763216AbYESVzY@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global 
myri10ge_get_firmware_capabilities() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
0442d0c2cb767d312f5264cc226a1595c47f3dbf diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c91b12e..36be6ef 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -631,7 +631,7 @@ static int myri10ge_adopt_running_firmware(struct myri10ge_priv *mgp)
 	return status;
 }
 
-int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
+static int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_cmd cmd;
 	int status;
