From: Karlis Peisenieks <karlis@mt.lv>
Subject: bridge bug
Date: Thu, 4 Sep 2003 13:19:00 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904101900.GA32077@mt.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Attached patch fixed memory leak in 2.4.22 bridge. Have not checked 
2.6.x versions.


Karlis

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- br_stp_bpdu.c	27 Aug 2003 10:42:07 -0000	1.1.1.3
+++ br_stp_bpdu.c	4 Sep 2003 10:17:17 -0000
@@ -194,6 +194,6 @@
 	}
 
  err:
-	kfree(skb);
+	kfree_skb(skb);
 	return 0;
 }

--y0ulUmNC+osPPQO6--
