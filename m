From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/2] bpf: Allow selecting numa node during map creation
Date: Fri, 18 Aug 2017 11:27:59 -0700
Message-ID: <20170818182801.2518162-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48001 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751609AbdHRS2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 14:28:04 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v7IINbYJ015111
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:28:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2ce3dc8rw3-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:28:04 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 f80717d4844211e79d280002c99293a0-39615150 for <netdev@vger.kernel.org>;        Fri,
 18 Aug 2017 11:28:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series allows user to pick the numa node during map creation.
The first patch has the details

Martin KaFai Lau (2):
  bpf: Allow selecting numa node during map creation
  bpf: Allow numa selection in INNER_LRU_HASH_PREALLOC test of
    map_perf_test

 include/linux/bpf.h                       | 10 +++++++++-
 include/uapi/linux/bpf.h                  | 10 +++++++++-
 kernel/bpf/arraymap.c                     |  7 +++++--
 kernel/bpf/devmap.c                       |  9 ++++++---
 kernel/bpf/hashtab.c                      | 19 ++++++++++++++----
 kernel/bpf/lpm_trie.c                     |  9 +++++++--
 kernel/bpf/sockmap.c                      | 10 +++++++---
 kernel/bpf/stackmap.c                     |  8 +++++---
 kernel/bpf/syscall.c                      | 14 ++++++++++----
 samples/bpf/bpf_load.c                    | 21 ++++++++++++--------
 samples/bpf/bpf_load.h                    |  1 +
 samples/bpf/map_perf_test_kern.c          |  2 ++
 samples/bpf/map_perf_test_user.c          | 12 +++++++++---
 tools/include/uapi/linux/bpf.h            | 10 +++++++++-
 tools/lib/bpf/bpf.c                       | 32 +++++++++++++++++++++++++++----
 tools/lib/bpf/bpf.h                       |  6 ++++++
 tools/testing/selftests/bpf/bpf_helpers.h |  1 +
 17 files changed, 142 insertions(+), 39 deletions(-)

-- 
2.9.5
