From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Fri, 14 Apr 2006 13:44:46 +0200
Message-ID: <20060414114446.GL4162@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932315AbWDNLot@vger.kernel.org>
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the following unused EXPORT_SYMBOL's:
- irias_find_attrib
- irias_new_string_value
- irias_new_octseq_value

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/irda/irias_object.c |    3 ---
 1 file changed, 3 deletions(-)

--- linux-2.6.17-rc1-mm2-full/net/irda/irias_object.c.old	2006-04-14 12:37:49.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/irda/irias_object.c	2006-04-14 12:39:26.000000000 +0200
@@ -257,7 +257,6 @@
 	/* Unsafe (locking), attrib might change */
 	return attrib;
 }
-EXPORT_SYMBOL(irias_find_attrib);
 
 /*
  * Function irias_add_attribute (obj, attrib)
@@ -484,7 +483,6 @@
 
 	return value;
 }
-EXPORT_SYMBOL(irias_new_string_value);
 
 /*
  * Function irias_new_octseq_value (octets, len)
@@ -519,7 +517,6 @@
 	memcpy(value->t.oct_seq, octseq , len);
 	return value;
 }
-EXPORT_SYMBOL(irias_new_octseq_value);
 
 struct ias_value *irias_new_missing_value(void)
 {
