From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 6/6]x25:dte facilities 32 64 ioctl conversion
Date: Fri, 17 Feb 2006 16:02:55 +1100
Message-ID: <1140152575.1475.27.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andre Hendry <ahendry@tusc.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932276AbWBQFGI@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: spereira@tusc.com.au

Allows dte facility patch to use 32 64 bit ioctl
conversion mechanism

Signed-off-by:Shaun Pereira <spereira@tusc.com.au>
---
diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/x25/af_x25.c linux-2.6.16-rc3/net/x25/af_x25.c
--- linux-2.6.16-rc3-vanilla/net/x25/af_x25.c	2006-02-16 15:33:48.000000000 +1100
+++ linux-2.6.16-rc3/net/x25/af_x25.c	2006-02-16 15:34:05.000000000 +1100
@@ -1529,6 +1529,8 @@ static int compat_x25_ioctl(struct socke
 			break;
 		case SIOCX25GFACILITIES:
 		case SIOCX25SFACILITIES:
+		case SIOCX25GDTEFACILITIES:
+		case SIOCX25SDTEFACILITIES:
 		case SIOCX25GCALLUSERDATA:
 		case SIOCX25SCALLUSERDATA:
 		case SIOCX25GCAUSEDIAG:
