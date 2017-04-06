From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] selftests/bpf: fix merge conflict
Date: Thu, 6 Apr 2017 12:20:26 -0700
Message-ID: <20170406192026.2545336-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60433 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754690AbdDFTU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:20:29 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v36JIpwi020422
        for <netdev@vger.kernel.org>; Thu, 6 Apr 2017 12:20:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 29ntxt859c-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 12:20:28 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 16e201901afe11e793cb24be05904660-50ffa9a0 for <netdev@vger.kernel.org>;        Thu,
 06 Apr 2017 12:20:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix artifact of merge resolution

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_verifier.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0963f8ffd25c..6178b65fee59 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -4904,12 +4904,7 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	struct bpf_insn *prog = test->insns;
 	int prog_len = probe_filter_length(prog);
 	int prog_type = test->prog_type;
-<<<<<<< HEAD
 	int map_fds[MAX_NR_MAPS];
-	int fd_prog, expected_ret;
-=======
-	int fd_f1 = -1, fd_f2 = -1, fd_f3 = -1;
->>>>>>> ea6b1720ce25f92f7a17b2e0c2b653d20773d10a
 	const char *expected_err;
 	int i;
 
-- 
2.9.3
