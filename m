From: akpm@linux-foundation.org
Subject: [patch 01/28] fore200e_param_bs_queue() must be __devinit
Date: Fri, 10 Aug 2007 14:11:48 -0700
Message-ID: <200708102111.l7ALBm47009367@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36649 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942191AbXHJVME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

WARNING: drivers/built-in.o(.text+0x6203bb): Section mismatch: reference to .init.text:fore200e_param_bs_queue (between 'fore200e_initialize' and 'fore200e_monitor_putc')

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/fore200e.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/atm/fore200e.c~fore200e_param_bs_queue-must-be-__devinit drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c~fore200e_param_bs_queue-must-be-__devinit
+++ a/drivers/atm/fore200e.c
@@ -2435,7 +2435,7 @@ fore200e_init_cmd_queue(struct fore200e*
 }
 
 
-static void __init
+static void __devinit
 fore200e_param_bs_queue(struct fore200e* fore200e,
 			enum buffer_scheme scheme, enum buffer_magn magn,
 			int queue_length, int pool_size, int supply_blksize)
_
