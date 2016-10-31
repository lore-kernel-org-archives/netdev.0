From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/4] net: pim: add a helper to check for IPv4 all pim routers address
Date: Mon, 31 Oct 2016 13:21:03 +0100
Message-ID: <1477916465-20406-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dwalton@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37320 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941390AbcJaMVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:21:19 -0400
Received: by mail-wm0-f49.google.com with SMTP id t79so46324594wmt.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:21:19 -0700 (PDT)
In-Reply-To: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/pim.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/pim.h b/include/linux/pim.h
index 354235a2691b..1b6c0dbba94e 100644
--- a/include/linux/pim.h
+++ b/include/linux/pim.h
@@ -57,4 +57,10 @@ static inline u8 pim_hdr_type(const struct pimhdr *pimhdr)
 {
 	return pimhdr->type & 0xf;
 }
+
+/* check if the address is 224.0.0.13, RFC7761 sec 4.3.1 */
+static inline bool pim_ipv4_all_pim_routers(__be32 addr)
+{
+	return addr == htonl(0xE000000D);
+}
 #endif
-- 
2.1.4
