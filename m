From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH RFC 1/2] bpf: Add a BPF return code to disconnect a connection
Date: Mon,  7 Aug 2017 15:12:03 -0700
Message-ID: <20170807221204.15724-2-tom@quantonium.net>
References: <20170807221204.15724-1-tom@quantonium.net>
Cc: rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35250 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdHGWMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 18:12:45 -0400
Received: by mail-pg0-f44.google.com with SMTP id v189so6712141pgd.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 15:12:45 -0700 (PDT)
In-Reply-To: <20170807221204.15724-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using BPF program against a flow a possible verdict is that the
packet should not only be dropped, but that the flow the packet
was received on should be terminated.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/uapi/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1d06be1569b1..324e886c3490 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -708,6 +708,7 @@ enum bpf_ret_code {
 	BPF_DROP = 2,
 	/* 3-6 reserved */
 	BPF_REDIRECT = 7,
+	BPF_DISCONNECT = 8,
 	/* >127 are reserved for prog type specific return codes */
 };
 
-- 
2.11.0
