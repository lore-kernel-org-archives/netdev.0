From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Wed, 18 Feb 2015 14:39:09 -0500
Message-ID: <20150218193909.GB580@gospo.home.greyhouse.net>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
 <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
 <20150213212830.GA29912@electric-eye.fr.zoreil.com>
 <54E1568D.5000100@windriver.com>
 <20150216120345.4dfd9950@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yzhu1 <Yanjun.Zhu@windriver.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	mst@redhat.com, jasowang@redhat.com, viro@zeniv.linux.org.uk,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	jonathon.reinhart@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:44739 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbbBRTjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:39:13 -0500
Received: by mail-qa0-f49.google.com with SMTP id w8so2377790qac.8
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:39:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150216120345.4dfd9950@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proposed follow-up based on the errors in if_tunnel.h that were brought
to my attention with Stephen's patch.

(Dave, if you want a more official-looking post in a standalone thread I
can do that.)

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next] uapi: fixup whitespace for private ioctls

After Stephen's patch added support for new private ioctl (SIOCDRVINFO)
I noticed that his whitespace was correct, but the rest of the
whitespace for the other ioctls was wrong.  This fixes up the others and
should be applied after his.

CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

---
 include/uapi/linux/if_tunnel.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 3430238..4a65a56 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -5,18 +5,18 @@
 #include <asm/byteorder.h>
 
 
-#define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
-#define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
-#define SIOCDELTUNNEL   (SIOCDEVPRIVATE + 2)
-#define SIOCCHGTUNNEL   (SIOCDEVPRIVATE + 3)
-#define SIOCGETPRL      (SIOCDEVPRIVATE + 4)
-#define SIOCADDPRL      (SIOCDEVPRIVATE + 5)
-#define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
-#define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
-#define SIOCGET6RD      (SIOCDEVPRIVATE + 8)
-#define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
-#define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
-#define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
+#define SIOCGETTUNNEL	(SIOCDEVPRIVATE + 0)
+#define SIOCADDTUNNEL	(SIOCDEVPRIVATE + 1)
+#define SIOCDELTUNNEL	(SIOCDEVPRIVATE + 2)
+#define SIOCCHGTUNNEL	(SIOCDEVPRIVATE + 3)
+#define SIOCGETPRL	(SIOCDEVPRIVATE + 4)
+#define SIOCADDPRL	(SIOCDEVPRIVATE + 5)
+#define SIOCDELPRL	(SIOCDEVPRIVATE + 6)
+#define SIOCCHGPRL	(SIOCDEVPRIVATE + 7)
+#define SIOCGET6RD	(SIOCDEVPRIVATE + 8)
+#define SIOCADD6RD	(SIOCDEVPRIVATE + 9)
+#define SIOCDEL6RD	(SIOCDEVPRIVATE + 10)
+#define SIOCCHG6RD	(SIOCDEVPRIVATE + 11)
 #define SIOCDRVINFO	(SIOCDEVPRIVATE + 12)
 
 struct ip_tunnel_info {
-- 
1.9.3
