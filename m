From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next] tcp: add tracepoint trace_tcp_retransmit_synack
Date: Mon, 30 Oct 2017 14:41:34 -0700
Message-ID: <20171030214135.2444870-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37634 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751654AbdJ3Vln (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:41:43 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9ULdreQ018972
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:41:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dxam38fe9-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:41:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from v1: Updated commit message to highlight potential sparse warning.

Song Liu (1):
  tcp: add tracepoint trace_tcp_retransmit_synack()

 include/trace/events/tcp.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c      |  1 +
 2 files changed, 57 insertions(+)
