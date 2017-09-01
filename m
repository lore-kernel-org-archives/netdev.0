From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/3] bpf: Improve LRU map lookup performance
Date: Thu, 31 Aug 2017 23:27:10 -0700
Message-ID: <20170901062713.1842249-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36472 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751000AbdIAG1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 02:27:15 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v816OnLN009163
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:14 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cq180r9r6-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset improves the lookup performance of the LRU map.
Please see individual patch for details.

Martin KaFai Lau (3):
  bpf: Add lru_hash_lookup performance test
  bpf: Inline LRU map lookup
  bpf: Only set node->ref = 1 if it has not been set

 kernel/bpf/bpf_lru_list.h        |  3 +-
 kernel/bpf/hashtab.c             | 24 +++++++++++++
 samples/bpf/map_perf_test_kern.c | 44 +++++++++++++++++++----
 samples/bpf/map_perf_test_user.c | 77 ++++++++++++++++++++++++++++++++++++++--
 4 files changed, 138 insertions(+), 10 deletions(-)

-- 
2.9.5
