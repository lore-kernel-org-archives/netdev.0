From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: [PATCH] Documentation: Mention chunk format for irq affinity
Date: Wed, 22 Jul 2015 10:09:36 +0200
Message-ID: <1437552576.2783.19.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37375 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbbGVIJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 04:09:39 -0400
Received: by wibud3 with SMTP id ud3so159732856wib.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 01:09:38 -0700 (PDT)
Received: from de-ka-36785.green.sophos ([2001:1a80:2000:2:4637:e6ff:feaa:80c4])
        by smtp.googlemail.com with ESMTPSA id da5sm2082405wib.6.2015.07.22.01.09.37
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Wed, 22 Jul 2015 01:09:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may not be obvious for everyone that bitmasks in proc require
32bit chunking
    
Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
---
 Documentation/IRQ-affinity.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/IRQ-affinity.txt b/Documentation/IRQ-affinity.txt
index 01a6751..d873dab 100644
--- a/Documentation/IRQ-affinity.txt
+++ b/Documentation/IRQ-affinity.txt
@@ -55,6 +55,11 @@ round-trip min/avg/max = 0.1/0.5/585.4 ms
 This time around IRQ44 was delivered only to the last four processors.
 i.e counters for the CPU0-3 did not change.
 
+Note that you have to split the bitmask to chunks when using more that 32 cpus:
+[root@moon 44]# echo 80,00000000 > smp_affinity
+[root@moon 44]# cat smp_affinity
+80,00000000
+
 Here is an example of limiting that same irq (44) to cpus 1024 to 1031:
 
 [root@moon 44]# echo 1024-1031 > smp_affinity_list
-- 
2.4.3
