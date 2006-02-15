From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 6/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 09:43:35 +1100
Message-ID: <1140043416.8745.52.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751129AbWBOWpg@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kenel <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow patch 5 to use 32-64 bit conversion mechanism

Signed-off-by:Shaun Pereira <spereira@tusc.com.au>

diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/x25/af_x25.c linux-2.6.16-rc3/net/x25/af_x25.c
--- linux-2.6.16-rc3-vanilla/net/x25/af_x25.c	2006-02-15 11:17:03.000000000 +1100
+++ linux-2.6.16-rc3/net/x25/af_x25.c	2006-02-15 11:17:20.000000000 +1100
@@ -1529,6 +1529,8 @@ static int compat_x25_ioctl(struct socke
 			break;
 		case SIOCX25GFACILITIES:
 		case SIOCX25SFACILITIES:
+		case SIOCX25GDTEFACILITIES:
+		case SIOCX25SDTEFACILITIES:
 		case SIOCX25GCALLUSERDATA:
 		case SIOCX25SCALLUSERDATA:
 		case SIOCX25GCAUSEDIAG:
