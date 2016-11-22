From: Daniel.Hopf@continental-corporation.com
Subject: [PATCH] iproute2: Nr. of packets and octets for macsec tx stats were
 swapped.
Date: Tue, 22 Nov 2016 14:24:40 +0100
Message-ID: <OFDC737720.EA272892-ONC1258073.00458CA2-C1258073.0049AC0D@continental-corporation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.de1.retarus.com ([94.199.92.161]:44652 "EHLO
        mailout01.de1.retarus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755731AbcKVNcG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 08:32:06 -0500
Received: from kdin02.de1.retarus.com (unknown [10.241.12.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mailout01.de1.retarus.com (Postfix) with ESMTPS id 3tNR5n4K2Gz4ywtM
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 14:24:45 +0100 (CET)
Received: from FRHB104.fr.ge.conti.de (unknown [10.220.1.11])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by kdin02.de1.retarus.com (Postfix) with ESMTPS id 3tNR5n2Fw5z374Kb
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 14:24:45 +0100 (CET)
Received: from frhb104.fr.ge.conti.de (FRHB104.fr.ge.conti.de [172.29.14.42])
        by FRHB104.fr.ge.conti.de (8.14.4/8.14.4) with ESMTP id uAMDOic5065226
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 14:24:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hopf <daniel.hopf@continental-corporation.com>
---
 ip/ipmacsec.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index c9252bb..aa89a00 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -634,10 +634,10 @@ static void print_one_stat(const char **names, 
struct rtattr **attr, int idx,
 }

 static const char *txsc_stats_names[NUM_MACSEC_TXSC_STATS_ATTR] = {
-       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = 
"OutOctetsProtected",
-       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = 
"OutOctetsEncrypted",
-       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
"OutPktsProtected",
-       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
"OutPktsEncrypted",
+       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = "OutPktsProtected",
+       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = "OutPktsEncrypted",
+       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
"OutOctetsProtected",
+       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
"OutOctetsEncrypted",
 };

 static void print_txsc_stats(const char *prefix, struct rtattr *attr)
