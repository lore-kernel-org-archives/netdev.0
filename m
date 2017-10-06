From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/3] bpf: Misc improvements and a new usage on bpf obj name
Date: Thu, 5 Oct 2017 21:52:10 -0700
Message-ID: <20171006045213.752372-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44040 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750813AbdJFEwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:52:19 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v964o7n6021771
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 21:52:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ddxebh5he-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 21:52:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two patches make improvements on the bpf obj name.

The last patch adds the prog name to kallsyms.

Martin KaFai Lau (3):
  bpf: Change bpf_obj_name_cpy() to better ensure map's name is init by
    0
  bpf: Use char in prog and map name
  bpf: Append prog->aux->name in bpf_get_prog_name()

 include/linux/bpf.h            |  4 ++--
 include/uapi/linux/bpf.h       |  8 ++++----
 kernel/bpf/core.c              | 17 +++++++++++++++--
 kernel/bpf/syscall.c           |  5 ++---
 tools/include/uapi/linux/bpf.h |  8 ++++----
 5 files changed, 27 insertions(+), 15 deletions(-)

-- 
2.9.5
