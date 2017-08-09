From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH iproute2 master] examples/bpf: update list of examples
Date: Wed,  9 Aug 2017 05:39:07 +0200
Message-ID: <20170809033907.9194-1-alexander@alemayhu.com>
Cc: stephen@networkplumber.org,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs224.mailgun.us ([209.61.151.224]:62941 "EHLO rs224.mailgun.us"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752497AbdHIDoj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 23:44:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove deleted examples and add the new map in map example.

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 examples/bpf/README | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/examples/bpf/README b/examples/bpf/README
index 4247257850eb..1bbdda3f8dc1 100644
--- a/examples/bpf/README
+++ b/examples/bpf/README
@@ -1,13 +1,8 @@
 eBPF toy code examples (running in kernel) to familiarize yourself
 with syntax and features:
 
- - bpf_prog.c		-> Classifier examples with using maps
  - bpf_shared.c		-> Ingress/egress map sharing example
  - bpf_tailcall.c	-> Using tail call chains
  - bpf_cyclic.c		-> Simple cycle as tail calls
  - bpf_graft.c		-> Demo on altering runtime behaviour
-
-User space code example:
-
- - bpf_agent.c		-> Counterpart to bpf_prog.c for user
-                           space to transfer/read out map data
+ - bpf_map_in_map.c     -> Using map in map example
-- 
2.13.3
