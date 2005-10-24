From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]IPv6: fix refcnt of struct ip6_flowlabel
Date: Mon, 24 Oct 2005 20:11:39 +0800
Message-ID: <435CCF7B.6030907@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750943AbVJXMKQ@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yan Zheng <yanzheng@21cn.com>


Index: net/ipv6/ip6_flowlabel.c
===================================================================
--- linux-2.6.14-rc5/net/ipv6/ip6_flowlabel.c	2005-10-22 10:31:13.000000000 +0800
+++ linux/net/ipv6/ip6_flowlabel.c	2005-10-24 19:55:23.000000000 +0800
@@ -483,7 +483,7 @@
 						goto done;
 					}
 					fl1 = sfl->fl;
-					atomic_inc(&fl->users);
+					atomic_inc(&fl1->users);
 					break;
 				}
 			}
