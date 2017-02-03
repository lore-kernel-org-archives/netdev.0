From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/27] netfilter: nf_tables: add missing descriptions in nft_ct_keys
Date: Fri,  3 Feb 2017 13:25:14 +0100
Message-ID: <1486124738-3013-4-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58838 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752712AbdBCM2e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:34 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 652E1BA70D
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:33 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 51E4BDA818
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:33 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 419D7DA841
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:31 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

We missed to add descriptions about NFT_CT_LABELS, NFT_CT_PKTS and
NFT_CT_BYTES, now add it.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 881d49e94569..5726f90bfc2f 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -860,6 +860,9 @@ enum nft_rt_attributes {
  * @NFT_CT_PROTOCOL: conntrack layer 4 protocol
  * @NFT_CT_PROTO_SRC: conntrack layer 4 protocol source
  * @NFT_CT_PROTO_DST: conntrack layer 4 protocol destination
+ * @NFT_CT_LABELS: conntrack labels
+ * @NFT_CT_PKTS: conntrack packets
+ * @NFT_CT_BYTES: conntrack bytes
  */
 enum nft_ct_keys {
 	NFT_CT_STATE,
-- 
2.1.4
