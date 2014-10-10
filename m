From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] Documentation: replace __sk_run_filter with __bpf_prog_run
Date: Fri, 10 Oct 2014 11:36:54 +0800
Message-ID: <1412912214-964-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:40952 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaJJDhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 23:37:05 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so867964pdb.31
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 20:37:04 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id yw3sm1853041pbc.88.2014.10.09.20.37.02
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 20:37:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

__sk_run_filter has been renamed as __bpf_prog_run, so replace them in comments

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 Documentation/networking/filter.txt |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 5ce4d07..c22b797 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -700,11 +700,11 @@ Some core changes of the new internal format:
     bpf_exit
 
   If f2 is JITed and the pointer stored to '_f2'. The calls f1 -> f2 -> f3 and
-  returns will be seamless. Without JIT, __sk_run_filter() interpreter needs to
+  returns will be seamless. Without JIT, __bpf_prog_run() interpreter needs to
   be used to call into f2.
 
   For practical reasons all eBPF programs have only one argument 'ctx' which is
-  already placed into R1 (e.g. on __sk_run_filter() startup) and the programs
+  already placed into R1 (e.g. on __bpf_prog_run() startup) and the programs
   can call kernel functions with up to 5 arguments. Calls with 6 or more arguments
   are currently not supported, but these restrictions can be lifted if necessary
   in the future.
-- 
1.7.10.4
