From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v6 07/12] bpf: add XDP_TX xdp_action for direct forwarding
Date: Thu,  7 Jul 2016 19:15:19 -0700
Message-ID: <1467944124-14891-8-git-send-email-bblanco@plumgrid.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
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
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34599 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcGHCPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 22:15:44 -0400
Received: by mail-pa0-f42.google.com with SMTP id bz2so11032192pad.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 19:15:43 -0700 (PDT)
In-Reply-To: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP enabled drivers must transmit received packets back out on the same
port they were received on when a program returns this action.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/uapi/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 5b47ac3..e3c3b92 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -439,6 +439,7 @@ struct bpf_tunnel_key {
 enum xdp_action {
 	XDP_DROP,
 	XDP_PASS,
+	XDP_TX,
 };
 
 /* user accessible metadata for XDP packet hook
-- 
2.8.2
