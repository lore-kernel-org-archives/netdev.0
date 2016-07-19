From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v10 08/12] bpf: add XDP_TX xdp_action for direct forwarding
Date: Tue, 19 Jul 2016 12:16:53 -0700
Message-ID: <1468955817-10604-9-git-send-email-bblanco@plumgrid.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34536 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbcGSTRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 15:17:33 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so10203313pfb.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 12:17:32 -0700 (PDT)
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP enabled drivers must transmit received packets back out on the same
port they were received on when a program returns this action.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index a517865..2b7076f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -449,6 +449,7 @@ enum xdp_action {
 	XDP_ABORTED = 0,
 	XDP_DROP,
 	XDP_PASS,
+	XDP_TX,
 };
 
 /* user accessible metadata for XDP packet hook
-- 
2.8.2
