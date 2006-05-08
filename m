From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: [PATCH 2/4] IrDA: Removing unused EXPORT_SYMBOLs
Date: Tue, 9 May 2006 00:23:44 +0300
Message-ID: <20060508212343.GC20933@irie>
Reply-To: Samuel Ortiz <samuel.ortiz@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>,
	IrDA users <irda-users@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext11.nokia.com ([131.228.20.170]:30665 "EHLO
	mgw-ext11.nokia.com") by vger.kernel.org with ESMTP
	id S1751268AbWEHVd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 17:33:27 -0400
To: "ext David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the following unused EXPORT_SYMBOL's:
- irias_find_attrib
- irias_new_string_value
- irias_new_octseq_value

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

---

 net/irda/irias_object.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

49586f340ee5f31ff40d142b32d8a15ca001bf4b
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index c6d169f..82e665c 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -257,7 +257,6 @@ struct ias_attrib *irias_find_attrib(str
 	/* Unsafe (locking), attrib might change */
 	return attrib;
 }
-EXPORT_SYMBOL(irias_find_attrib);
 
 /*
  * Function irias_add_attribute (obj, attrib)
@@ -484,7 +483,6 @@ struct ias_value *irias_new_string_value
 
 	return value;
 }
-EXPORT_SYMBOL(irias_new_string_value);
 
 /*
  * Function irias_new_octseq_value (octets, len)
@@ -519,7 +517,6 @@ struct ias_value *irias_new_octseq_value
 	memcpy(value->t.oct_seq, octseq , len);
 	return value;
 }
-EXPORT_SYMBOL(irias_new_octseq_value);
 
 struct ias_value *irias_new_missing_value(void)
 {
-- 
1.2.4

