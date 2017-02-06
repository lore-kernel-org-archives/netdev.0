From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute 5/5] tc: bash-completion: Add support for matchall
Date: Mon,  6 Feb 2017 15:19:24 +0200
Message-ID: <1486387164-40404-6-git-send-email-yotamg@mellanox.com>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51779 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751617AbdBFNQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:16:54 -0500
In-Reply-To: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the matchall classifier and its parameters.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/bash-completion/tc b/bash-completion/tc
index e4c6804..80d1297 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -5,7 +5,7 @@
 QDISC_KIND=' choke codel bfifo pfifo pfifo_head_drop fq fq_codel gred hhf \
             mqprio multiq netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
             dsmark hfsc htb prio qfq '
-FILTER_KIND=' basic bpf cgroup flow flower fw route rsvp tcindex u32 '
+FILTER_KIND=' basic bpf cgroup flow flower fw route rsvp tcindex u32 matchall '
 ACTION_KIND=' gact mirred bpf sample '
 
 # Takes a list of words in argument; each one of them is added to COMPREPLY if
@@ -449,6 +449,10 @@ _tc_filter_options()
             _tc_once_attr 'map hash divisor baseclass match action'
             return 0
             ;;
+        matchall)
+            _tc_once_attr 'action skip_sw skip_hw'
+            return 0
+            ;;
         flower)
             _tc_once_attr 'action classid indev dst_mac src_mac eth_type \
                 ip_proto dst_ip src_ip dst_port src_port'
-- 
2.4.11
