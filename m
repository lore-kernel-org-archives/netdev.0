From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 14:14:27 +0200
Message-ID: <20170411121427.GB5207@gmail.com>
References: <20170411113538.31423-1-alexander@alemayhu.com>
 <58ECC2B6.1020104@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34302 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751790AbdDKMOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 08:14:30 -0400
Received: by mail-lf0-f47.google.com with SMTP id z15so85815311lfd.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 05:14:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58ECC2B6.1020104@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 01:49:10PM +0200, Daniel Borkmann wrote:
> 
> Good point, we should also add '*.o' in that case for the
> TEST_GEN_FILES specified objs that clang generates.

Think that is covered by other files but added. Would it be
okay to ignore all the generated files, like the below?

commit 1036c0af4dc381c2571947f197c9d30c2c9f4510
Author: Alexander Alemayhu <alexander@alemayhu.com>
Date:   Tue Apr 11 13:31:32 2017 +0200

    bpf: ignore generated files
    
    o add test_progs to tools/testing/selftests/bpf/.gitignore and the other
    generated files.
    o new ignore file in samples/bpf
    
    Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
new file mode 100644
index 000000000000..6537659507f1
--- /dev/null
+++ b/samples/bpf/.gitignore
@@ -0,0 +1,35 @@
+fds_example
+lathist
+lwt_len_hist
+map_perf_test
+offwaketime
+per_socket_stats_example
+sampleip
+sock_example
+sockex1
+sockex2
+sockex3
+spintest
+tc_l2_redirect
+test_cgrp2_array_pin
+test_cgrp2_attach
+test_cgrp2_attach2
+test_cgrp2_sock
+test_cgrp2_sock2
+test_current_task_under_cgroup
+test_lru_dist
+test_map_in_map
+test_overhead
+test_probe_write_user
+trace_event
+trace_output
+tracex1
+tracex2
+tracex3
+tracex4
+tracex5
+tracex6
+xdp1
+xdp2
+xdp_tx_iptunnel
+*.o
diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
index 541d9d7fad5a..78c8fb7077e0 100644
--- a/tools/testing/selftests/bpf/.gitignore
+++ b/tools/testing/selftests/bpf/.gitignore
@@ -3,3 +3,8 @@ test_maps
 test_lru_map
 test_lpm_map
 test_tag
+test_progs
+FEATURE-DUMP.libbpf
+feature/
+fixdep
+*.o

Thanks.

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
