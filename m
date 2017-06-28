From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/2] bpf: Add syscall lookup support for fd array and htab
Date: Tue, 27 Jun 2017 23:08:33 -0700
Message-ID: <20170628060835.2142549-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51618 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751512AbdF1GIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 02:08:37 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5S680rT021501
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bc02rrv7d-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:37 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 387b41f85bc811e7b13d0002c99293a0-ec1328f0 for <netdev@vger.kernel.org>;        Tue,
 27 Jun 2017 23:08:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds BPF_MAP_LOOKUP_ELEM syscall support for
BPF_MAP_TYPE_PROG_ARRAY,
BPF_MAP_TYPE_ARRAY_OF_MAPS and
BPF_MAP_TYPE_HASH_OF_MAPS

Martin KaFai Lau (2):
  bpf: Add syscall lookup support for fd array and htab
  bpf: Add test for syscall on fd array/htab lookup

 include/linux/bpf.h                |  3 +++
 kernel/bpf/arraymap.c              | 27 +++++++++++++++++++++++++++
 kernel/bpf/hashtab.c               | 21 +++++++++++++++++++++
 kernel/bpf/map_in_map.c            |  5 +++++
 kernel/bpf/map_in_map.h            |  1 +
 kernel/bpf/syscall.c               | 16 +++++++++++++---
 samples/bpf/sockex3_user.c         | 15 ++++++++++++++-
 samples/bpf/test_map_in_map_user.c | 17 +++++++++++++++++
 8 files changed, 101 insertions(+), 4 deletions(-)

-- 
2.9.3
