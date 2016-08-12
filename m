From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/3] bpf improvements
Date: Thu, 11 Aug 2016 18:17:15 -0700
Message-ID: <1470964638-1313057-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19118 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751556AbcHLBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 21:17:22 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7C18mka009462
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 24rdh7ej8x-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:21 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 839dfd5a602a11e6a45e0002c992ebde-feffaaa0 for <netdev@vger.kernel.org>;	Thu,
 11 Aug 2016 18:17:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two bpf improvements:
1. allow bpf helpers like bpf_map_lookup_elem() access packet data directly
  for XDP programs
2. enable bpf_get_prandom_u32() for tracing programs

Aaron Yue (1):
  samples/bpf: add verifier tests for the helper access to the packet

Alexei Starovoitov (2):
  bpf: allow helpers access the packet directly
  bpf: allow bpf_get_prandom_u32() to be used in tracing

 kernel/bpf/verifier.c       |  61 +++++++++++++++++-------
 kernel/trace/bpf_trace.c    |   2 +
 samples/bpf/test_verifier.c | 114 ++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 155 insertions(+), 22 deletions(-)

-- 
2.8.0
