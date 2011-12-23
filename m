From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] packet: fix typo in packet_mmap.txt
Date: Fri, 23 Dec 2011 11:47:54 +0800
Message-ID: <CAPgLHd-YqSvDKDpsgyL5UJx1wK4MUOGw=LpMbWkENti=7MdkgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50869 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab1LWDrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 22:47:55 -0500
Received: by qcqz2 with SMTP id z2so5374838qcq.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 19:47:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Just fixed typo of sample code in packet_mmap.txt

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 4acea66..1c08a4b 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -155,7 +155,7 @@ As capture, each frame contains two parts:
 
  /* fill sockaddr_ll struct to prepare binding */
  my_addr.sll_family = AF_PACKET;
- my_addr.sll_protocol = ETH_P_ALL;
+ my_addr.sll_protocol = htons(ETH_P_ALL);
  my_addr.sll_ifindex =  s_ifr.ifr_ifindex;
 
  /* bind socket to eth0 */
-- 
1.7.7.4
