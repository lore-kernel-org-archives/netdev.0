From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, doc: fix typo on bpf_asm descriptions
Date: Mon, 16 May 2016 23:06:53 +0200
Message-ID: <e99246ae5491ccf99726ca78e78d58d8c41c78e7.1463432379.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, sebastian.amend@googlemail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35999 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcEPVHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 17:07:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix description of some of the bpf_asm tool related jump instructions
and generally move them to format A <op> k.

Reported-by: Sebastian Amend <sebastian.amend@googlemail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Documentation/networking/filter.txt | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 6aef0b5..b9a4edf 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -216,14 +216,14 @@ opcodes as defined in linux/filter.h stand for:
 
   jmp              6                    Jump to label
   ja               6                    Jump to label
-  jeq              7, 8                 Jump on k == A
-  jneq             8                    Jump on k != A
-  jne              8                    Jump on k != A
-  jlt              8                    Jump on k < A
-  jle              8                    Jump on k <= A
-  jgt              7, 8                 Jump on k > A
-  jge              7, 8                 Jump on k >= A
-  jset             7, 8                 Jump on k & A
+  jeq              7, 8                 Jump on A == k
+  jneq             8                    Jump on A != k
+  jne              8                    Jump on A != k
+  jlt              8                    Jump on A <  k
+  jle              8                    Jump on A <= k
+  jgt              7, 8                 Jump on A >  k
+  jge              7, 8                 Jump on A >= k
+  jset             7, 8                 Jump on A &  k
 
   add              0, 4                 A + <x>
   sub              0, 4                 A - <x>
-- 
1.9.3
