From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/5] bna: fix declaration mismatch
Date: Fri, 08 Mar 2013 11:07:40 -0800
Message-ID: <20130308190808.861866355@vyatta.com>
References: <20130308190739.260966567@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:37273 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab3CHTX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:23:28 -0500
Content-Disposition: inline; filename=bna-mismatch.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function is declared to take u32 but definition uses enum.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c	2013-03-08 10:33:19.142142147 -0800
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c	2013-03-08 10:33:21.534142211 -0800
@@ -76,7 +76,7 @@ static void bfa_ioc_pf_disabled(struct b
 static void bfa_ioc_pf_failed(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_hwfailed(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
-static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
+static void bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 			 u32 boot_param);
 static u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
 static void bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc,
