From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 6/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 16:48:01 +1100
Message-ID: <1140068881.4941.28.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932496AbWBPFuP@vger.kernel.org>
To: linux-kenel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

32 - 64 converstion for patch 5

Signed-off-by:Shaun Pereira <spereira@tusc.com.au>

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
