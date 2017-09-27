From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/5] bpf: Extend bpf_{prog,map}_info
Date: Wed, 27 Sep 2017 14:37:51 -0700
Message-ID: <20170927213756.1254938-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60036 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751957AbdI0Vh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:37:58 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RLYShg015871
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d8jaggmau-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds more fields to bpf_prog_info and bpf_map_info.
Please see individual patch for details.

Martin KaFai Lau (5):
  bpf: Add name, load_time, uid and map_ids to bpf_prog_info
  bpf: Add map_name to bpf_map_info
  bpf: libbpf: Provide basic API support to specify BPF obj name
  bpf: Swap the order of checking prog_info and map_info
  bpf: Test new fields in bpf_attr and bpf_{prog,map}_info

 include/linux/bpf.h                         |   3 +
 include/uapi/linux/bpf.h                    |  10 ++
 kernel/bpf/syscall.c                        |  58 ++++++++-
 samples/bpf/bpf_load.c                      |   2 +
 samples/bpf/map_perf_test_user.c            |   1 +
 tools/include/uapi/linux/bpf.h              |  10 ++
 tools/lib/bpf/bpf.c                         |  57 ++++++--
 tools/lib/bpf/bpf.h                         |  23 +++-
 tools/lib/bpf/libbpf.c                      | 109 ++++++++++++----
 tools/testing/selftests/bpf/test_progs.c    | 195 +++++++++++++++++++++++-----
 tools/testing/selftests/bpf/test_verifier.c |   2 +-
 11 files changed, 385 insertions(+), 85 deletions(-)

-- 
2.9.5
