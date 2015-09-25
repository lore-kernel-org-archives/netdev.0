From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH v2 17/19] tools: bpf_jit_disasm: make get_last_jit_image return
 unsigned
Date: Fri, 25 Sep 2015 08:45:43 +0200
Message-ID: <1443163543-25733-1-git-send-email-a.hajda@samsung.com>
References: <560446A2.2020907@iogearbox.net>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.w1.samsung.com ([210.118.77.12]:10261 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbbIYGqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 02:46:16 -0400
In-reply-to: <560446A2.2020907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function returns always non-negative values.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
v2: fixed indentation
---
 tools/net/bpf_jit_disasm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index 2cd3d4c..5b32413 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -156,8 +156,8 @@ static void put_log_buff(char *buff)
 	free(buff);
 }
 
-static int get_last_jit_image(char *haystack, size_t hlen,
-			      uint8_t *image, size_t ilen)
+static unsigned int get_last_jit_image(char *haystack, size_t hlen,
+				       uint8_t *image, size_t ilen)
 {
 	char *ptr, *pptr, *tmp;
 	off_t off = 0;
-- 
1.9.1
