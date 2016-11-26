From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Fri, 25 Nov 2016 23:23:47 -0800
Message-ID: <1480145027-3524392-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38109 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750783AbcKZHXt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 02:23:49 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAQ7NasG018705
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 23:23:49 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26y0a6a8w0-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 23:23:49 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 4598cdd2b3a911e6a9280002c95209d8-f74f7a50 for <netdev@vger.kernel.org>;        Fri,
 25 Nov 2016 23:23:48 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this #include is unnecessary and brings whole set of
other headers into cgroup-defs.h. Remove it.

Fixes: 3007098494be ("cgroup: add support for eBPF programs")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
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
