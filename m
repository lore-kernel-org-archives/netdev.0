From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH iproute2] ip: HSR: Fix cut and paste error
Date: Mon, 6 Feb 2017 21:47:35 +0100
Message-ID: <20170206204735.GA30232@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:55254 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdBFUri (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 15:47:38 -0500
Received: (from localhost user: 'ralf' uid#1000 fake: STDIN
        (ralf@eddie.linux-mips.org)) by eddie.linux-mips.org
        id S23991867AbdBFUrf62-L3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 21:47:35 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 5c0aec93a516 ("ip: Add HSR support")
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
I found this by coincidence when reading the HSR code.

 ip/iplink_hsr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
index cb744eb..696b2c9 100644
--- a/ip/iplink_hsr.c
+++ b/ip/iplink_hsr.c
@@ -144,7 +144,7 @@ static void hsr_print_help(struct link_util *lu, int argc, char **argv,
 
 struct link_util hsr_link_util = {
 	.id		= "hsr",
-	.maxattr	= IFLA_VLAN_MAX,
+	.maxattr	= IFLA_HSR_MAX,
 	.parse_opt	= hsr_parse_opt,
 	.print_opt	= hsr_print_opt,
 	.print_help	= hsr_print_help,
