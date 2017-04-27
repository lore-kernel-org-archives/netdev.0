From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC net-next 0/2] Introduce bpf_prog ID and iteration
Date: Wed, 26 Apr 2017 23:24:47 -0700
Message-ID: <20170427062449.80290-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55817 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751924AbdD0GYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 02:24:50 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3R6Oj2Y006284
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 23:24:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a34s4gwgg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 23:24:50 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 37226b602b1211e7a55a0002c99293a0-bfaf89a0 for <netdev@vger.kernel.org>;        Wed,
 26 Apr 2017 23:24:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces the bpf_prog ID and a new bpf cmd to
iterate all bpf_prog in the system.

It is still incomplete.  The idea can be extended to bpf_map.

Martin KaFai Lau (2):
  bpf: Introduce bpf_prog ID
  bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID

 include/linux/filter.h                     |  1 +
 include/uapi/linux/bpf.h                   |  6 ++
 kernel/bpf/syscall.c                       | 47 ++++++++++++++-
 tools/include/uapi/linux/bpf.h             |  6 ++
 tools/lib/bpf/bpf.c                        | 11 ++++
 tools/lib/bpf/bpf.h                        |  1 +
 tools/testing/selftests/bpf/Makefile       |  2 +-
 tools/testing/selftests/bpf/test_prog_id.c | 93 ++++++++++++++++++++++++++++++
 8 files changed, 165 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_prog_id.c

-- 
2.9.3
