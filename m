From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] tcp: remove unnecessary include
Date: Fri, 27 Oct 2017 10:01:39 -0700
Message-ID: <20171027170139.2811283-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Lawrence Brakmo <brakmo@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40750 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751561AbdJ0RB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 13:01:58 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9RGrGMK004150
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 10:01:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dv4xfrtx7-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 10:01:58 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

two extra #include are not necessary in tcp.h
Remove them.

Fixes: 40304b2a1567 ("bpf: BPF support for sock_ops")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
noticed that changes to linux/bpf.h triggered bigger kernel rebuilds
---
 include/net/tcp.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2392f74074e7..14a68d206dab 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -45,9 +45,6 @@
 
 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
-
-#include <linux/bpf.h>
-#include <linux/filter.h>
 #include <linux/bpf-cgroup.h>
 
 extern struct inet_hashinfo tcp_hashinfo;
-- 
2.9.5
