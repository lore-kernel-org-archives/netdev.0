From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Wed, 30 Nov 2016 10:16:08 -0800
Message-ID: <1480529768-1954199-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        Rami Rosen <roszenrami@gmail.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50630 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751150AbcK3SQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:16:12 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUIF5M2014792
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:16:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2722fagvdg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:16:11 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 1183c2dab72911e68b100002c9521c9e-45bf3a50 for <netdev@vger.kernel.org>;        Wed,
 30 Nov 2016 10:16:09 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this #include is unnecessary and brings whole set of
other headers into cgroup-defs.h. Remove it.

Fixes: 3007098494be ("cgroup: add support for eBPF programs")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Rami Rosen <roszenrami@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Daniel Mack <daniel@zonque.org>
---
Dave,
this patch got lost somehow (marked accepted, but not in net-next).
Resending.

 include/linux/bpf-cgroup.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index ec80d0c0953e..0cf1adfadd2d 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -1,7 +1,6 @@
 #ifndef _BPF_CGROUP_H
 #define _BPF_CGROUP_H
 
-#include <linux/bpf.h>
 #include <linux/jump_label.h>
 #include <uapi/linux/bpf.h>
 
-- 
2.8.0
