From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/5] bpf: verifier improvements
Date: Mon, 9 Jan 2017 10:19:45 -0800
Message-ID: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50325 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1164079AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09IJfBG007392
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27v9y1959a-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:52 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 36042a80d69811e699290002c9dfb610-2d9f5a50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of bpf verifier improvements from Gianluca.
See individual patches for details.

Alexei Starovoitov (1):
  bpf: rename ARG_PTR_TO_STACK

Gianluca Borello (4):
  bpf: split check_mem_access logic for map values
  bpf: allow helpers access to map element values
  bpf: allow adjusted map element values to spill
  bpf: allow helpers access to variable memory

 include/linux/bpf.h                         |  12 +-
 kernel/bpf/helpers.c                        |   4 +-
 kernel/bpf/verifier.c                       | 212 +++++--
 kernel/trace/bpf_trace.c                    |  20 +-
 net/core/filter.c                           |  40 +-
 tools/testing/selftests/bpf/test_verifier.c | 947 ++++++++++++++++++++++++++++
 6 files changed, 1131 insertions(+), 104 deletions(-)

-- 
2.8.0
