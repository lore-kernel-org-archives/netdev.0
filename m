From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 0/2] bpf: htab fixes
Date: Tue, 7 Mar 2017 20:00:11 -0800
Message-ID: <1488945613-1857856-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41654 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756677AbdCHEAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 23:00:16 -0500
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v283wJco013569
        for <netdev@vger.kernel.org>; Tue, 7 Mar 2017 20:00:15 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2925uwrtn2-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 20:00:15 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 bbbdeaec03b311e7b44f0002c99293a0-b45f39a0 for <netdev@vger.kernel.org>;        Tue,
 07 Mar 2017 20:00:14 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two bpf hashtable fixes. See individual patches for details.

Alexei Starovoitov (2):
  bpf: fix struct htab_elem layout
  bpf: convert htab map to hlist_nulls

 include/linux/list_nulls.h    |   5 ++
 include/linux/rculist_nulls.h |  14 +++++
 kernel/bpf/hashtab.c          | 119 ++++++++++++++++++++++++++++--------------
 3 files changed, 99 insertions(+), 39 deletions(-)

-- 
2.8.0
