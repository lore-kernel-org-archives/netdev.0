From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] irda: fix 16/32 bit confusion
Date: Fri, 19 May 2006 15:35:17 +0400
Message-ID: <20060519113516.GA17751@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:17579 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932284AbWESLgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 07:36:49 -0400
Received: by nf-out-0910.google.com with SMTP id o63so44929nfa
        for <netdev@vger.kernel.org>; Fri, 19 May 2006 04:36:48 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/irda/iriap.c
+++ 1/net/irda/iriap.c
@@ -544,7 +544,8 @@ static void iriap_getvaluebyclass_respon
 {
 	struct sk_buff *tx_skb;
 	int n;
-	__u32 tmp_be32, tmp_be16;
+	__u32 tmp_be32;
+	__be16 tmp_be16;
 	__u8 *fp;
 
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);

