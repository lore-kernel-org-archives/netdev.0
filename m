From: daniel.hopf@zebralla-it.de
Subject: [PATCH iproute2 v2] macsec: Nr. of packets and octets for macsec tx
 stats were swapped.
Date: Wed, 23 Nov 2016 07:34:31 +0000
Message-ID: <20161123073431.Horde.JMylwjcAn8TA3xQWzd6Asnb@webmail.zebralla-it.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zebralla-it.de ([87.230.18.236]:51910 "EHLO
        lvps87-230-18-236.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752680AbcKWHki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 02:40:38 -0500
Received: from lvps87-230-18-236.dedicated.hosteurope.de (unknown [IPv6:::1])
        by lvps87-230-18-236.dedicated.hosteurope.de (Postfix) with ESMTPSA id CD95C638
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 08:34:31 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resent from other mail address due to our company mail  
[clients|servers] stupidly forcing
line-breaks on plain-text e-mails. Also changed the subject format as  
suggested by Sabrina
and Rami.

Acked-by: Rami Rosen <roszenrami@gmail.com>
Acked-by: Sabrina Dubroca <sd@queasysnail.net>
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
-	[MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = "OutOctetsProtected",
-	[MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = "OutOctetsEncrypted",
-	[MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = "OutPktsProtected",
-	[MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = "OutPktsEncrypted",
+	[MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = "OutPktsProtected",
+	[MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = "OutPktsEncrypted",
+	[MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = "OutOctetsProtected",
+	[MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = "OutOctetsEncrypted",
  };

  static void print_txsc_stats(const char *prefix, struct rtattr *attr)
