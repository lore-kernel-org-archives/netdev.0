From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, doc: also add s390x as arch to sysctl description
Date: Mon, 21 Aug 2017 00:26:03 +0200
Message-ID: <23b5525b786a641eb777cf44839fd98189d27acb.1503267753.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44969 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753355AbdHTW0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 18:26:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like this was accidentally missed, so still add s390x
as supported eBPF JIT arch to bpf_jit_enable.

Fixes: 014cd0a368dc ("bpf: Update sysctl documentation to list all supported architectures")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Documentation/sysctl/net.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index d7c2b88..28596e0 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -49,6 +49,7 @@ two flavors of JITs, the newer eBPF JIT currently supported on:
   - ppc64
   - sparc64
   - mips64
+  - s390x
 
 And the older cBPF JIT supported on the following archs:
   - arm
-- 
1.9.3
