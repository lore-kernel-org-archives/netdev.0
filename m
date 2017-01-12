From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] lwt_bpf: bpf_lwt_prog_cmp() can be static
Date: Thu, 12 Jan 2017 14:39:28 +0000
Message-ID: <20170112143928.21496-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33270 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdALOjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:39:43 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so3835151pfg.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 06:39:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

net/core/lwt_bpf.c:355:5: warning:
 symbol 'bpf_lwt_prog_cmp' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/core/lwt_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index 71bb3e2..40ef8ae 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -352,7 +352,7 @@ static int bpf_encap_nlsize(struct lwtunnel_state *lwtstate)
 	       0;
 }
 
-int bpf_lwt_prog_cmp(struct bpf_lwt_prog *a, struct bpf_lwt_prog *b)
+static int bpf_lwt_prog_cmp(struct bpf_lwt_prog *a, struct bpf_lwt_prog *b)
 {
 	/* FIXME:
 	 * The LWT state is currently rebuilt for delete requests which
