From: Eric Leblond <eric@regit.org>
Subject: [PATCH 2/8] uapi linux bpf: add max value to enum
Date: Sun, 16 Oct 2016 23:18:28 +0200
Message-ID: <20161016211834.11732-3-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45253 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757097AbcJPVVP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:15 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be used to detect userspace trying to set invalid value.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 include/uapi/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f09c70b..570287f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -96,6 +96,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
+	__MAX_BPF_PROG_TYPE,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
-- 
2.9.3
