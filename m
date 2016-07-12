From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v8 07/11] bpf: add XDP_TX xdp_action for direct forwarding
Date: Tue, 12 Jul 2016 00:51:30 -0700
Message-ID: <1468309894-26258-8-git-send-email-bblanco@plumgrid.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36102 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbcGLHwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 03:52:44 -0400
Received: by mail-pa0-f51.google.com with SMTP id hu1so4076602pad.3
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 00:52:44 -0700 (PDT)
In-Reply-To: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP enabled drivers must transmit received packets back out on the same
port they were received on when a program returns this action.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4282d44..a8f1ea1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -447,6 +447,7 @@ enum xdp_action {
 	XDP_ABORTED = 0,
 	XDP_DROP,
 	XDP_PASS,
+	XDP_TX,
 };
 
 /* user accessible metadata for XDP packet hook
-- 
2.8.2
