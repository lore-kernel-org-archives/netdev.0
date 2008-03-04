From: akpm@linux-foundation.org
Subject: [patch 04/17] make s2io.c:init_tti() static
Date: Tue, 04 Mar 2008 15:19:22 -0800
Message-ID: <200803042319.m24NJMkr002672@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org,
	Ramkrishna.Vepa@neterion.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57024 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934890AbYCDXTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

Make the needlessly global init_tti() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Acked-by: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/s2io.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/s2io.c~make-s2iocinit_tti-static drivers/net/s2io.c
--- a/drivers/net/s2io.c~make-s2iocinit_tti-static
+++ a/drivers/net/s2io.c
@@ -1088,7 +1088,7 @@ static int s2io_print_pci_mode(struct s2
  *  '-1' on failure
  */
 
-int init_tti(struct s2io_nic *nic, int link)
+static int init_tti(struct s2io_nic *nic, int link)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
_
