From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] IFA_MAX sets wrong in rtnetlink.h
Date: Wed, 26 May 2004 13:50:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405261350.39088.mashirle@us.ibm.com>
References: <200403171130.30282.mashirle@us.ibm.com> <200405261319.55787.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_fMQtAzgrdHz5Ynj"
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200405261319.55787.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_fMQtAzgrdHz5Ynj
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

A tiny patch here for 2.6.6 kernel.

-- 
Thanks
Shirley Ma
IBM Linux Technology Center

--Boundary-00=_fMQtAzgrdHz5Ynj
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.6-max.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.6-max.patch"

diff -urN linux-2.6.6/include/linux/rtnetlink.h linux-2.6.6-max/include/linux/rtnetlink.h
--- linux-2.6.6/include/linux/rtnetlink.h	2004-05-09 19:33:13.000000000 -0700
+++ linux-2.6.6-max/include/linux/rtnetlink.h	2004-05-26 13:47:20.535090648 -0700
@@ -348,7 +348,7 @@
 	IFA_MULTICAST
 };
 
-#define IFA_MAX IFA_CACHEINFO
+#define IFA_MAX IFA_MULTICAST
 
 /* ifa_flags */
 

--Boundary-00=_fMQtAzgrdHz5Ynj--
