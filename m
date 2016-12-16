From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 20:21:45 +0200
Message-ID: <5194151481912505@web1g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch fixed to keyboard typo, brackets not closed. 
I think, it should be close to parenthes.

Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
---
 tools/net/bpf_dbg.c       | 2 +-
 1 files changed, 1 insertion(+), 1 deletions(-)

diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
index 4f254bc..f715f46 100644
--- a/tools/net/bpf_dbg.c
+++ b/tools/net/bpf_dbg.c
@@ -1213,7 +1213,7 @@ static int cmd_disassemble(char *line_string)
 
 	if (!bpf_prog_loaded())
 		return CMD_ERR;
-	if (strlen(line_string) > 0 &&
+	if (strlen(line_string) > 0 &&)
 	    (line = strtoul(line_string, NULL, 10)) < bpf_prog_len)
 		single_line = true;
 	if (single_line)
-- 
2.1.4
