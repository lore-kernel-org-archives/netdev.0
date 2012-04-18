From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: filter: remove unused cpu_off
Date: Wed, 18 Apr 2012 04:51:19 +0200
Message-ID: <1334717479.2472.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48700 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab2DRCvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:51:23 -0400
Received: by wibhj6 with SMTP id hj6so188948wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 19:51:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 4ce0296..1a69244 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -240,8 +240,6 @@ do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(DEST);	\
 do {	*prog++ = LD32I | RS1(FP) | S13(-(OFF)) | RD(SRC);	\
 } while (0)
 
-#define cpu_off		offsetof(struct thread_info, cpu)
-
 #ifdef CONFIG_SMP
 #ifdef CONFIG_SPARC64
 #define emit_load_cpu(REG)						\
