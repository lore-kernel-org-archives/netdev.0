From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf, doc: update list of architectures that do eBPF JIT
Date: Sun, 23 Apr 2017 09:01:00 -0700
Message-ID: <20170423160100.1155435-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41552 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1045794AbdDWQBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 12:01:02 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3NFxA1v028587
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 09:01:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a02fwk4vh-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 09:01:02 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 0bbb4a68283e11e7a38b24be05956610-c43fb9a0 for <netdev@vger.kernel.org>;        Sun,
 23 Apr 2017 09:01:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update the list and remove 'in the future' statement,
since all still alive 64-bit architectures now do eBPF JIT.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
mips64 is the only 'still alive' 64-bit arch without eBPF JIT :)
---
 Documentation/networking/filter.txt | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 683ada5ad81d..b69b205501de 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -595,10 +595,9 @@ got from bpf_prog_create(), and 'ctx' the given context (e.g.
 skb pointer). All constraints and restrictions from bpf_check_classic() apply
 before a conversion to the new layout is being done behind the scenes!
 
-Currently, the classic BPF format is being used for JITing on most of the
-architectures. x86-64, aarch64 and s390x perform JIT compilation from eBPF
-instruction set, however, future work will migrate other JIT compilers as well,
-so that they will profit from the very same benefits.
+Currently, the classic BPF format is being used for JITing on most 32-bit
+architectures, whereas x86-64, aarch64, s390x, powerpc64, sparc64 perform JIT
+compilation from eBPF instruction set.
 
 Some core changes of the new internal format:
 
-- 
2.9.3
