From: jamal <hadi@cyberus.ca>
Subject: PATCH: use proper Attribute for Action stats
Date: 23 Mar 2005 19:40:23 -0500
Message-ID: <1111624822.1039.7.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-s7TUX2g18MpCayPCLac/"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-s7TUX2g18MpCayPCLac/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Dave,
Action stats were being sent on the wrong TLV. Patch attached.

cheers,
jamal

--=-s7TUX2g18MpCayPCLac/
Content-Disposition: attachment; filename=p_kernel
Content-Type: text/plain; name=p_kernel; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/linux/rtnetlink.h	2005/03/22 17:53:07	1.1
+++ b/include/linux/rtnetlink.h	2005/03/22 17:53:34
@@ -699,7 +699,6 @@
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
-	TCA_ACT_STATS,
 	__TCA_MAX
 };
 
--- a/include/linux/pkt_cls.h	2005/03/22 17:54:23	1.1
+++ b/include/linux/pkt_cls.h	2005/03/22 17:55:15
@@ -80,6 +80,7 @@
 	TCA_ACT_KIND,
 	TCA_ACT_OPTIONS,
 	TCA_ACT_INDEX,
+	TCA_ACT_STATS,
 	__TCA_ACT_MAX
 };
 

--=-s7TUX2g18MpCayPCLac/--
