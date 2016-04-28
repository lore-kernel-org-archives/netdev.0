From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 0/3] bpf: fix several bugs
Date: Wed, 27 Apr 2016 18:56:19 -0700
Message-ID: <1461808582-1452466-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:12951 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbcD1B40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 21:56:26 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3S1qiEx002209
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22k36dhqrs-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:25 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 68cfc9ac0ce411e687f724be05956610-82dfcc50 for <netdev@vger.kernel.org>;	Wed,
 27 Apr 2016 18:56:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches address bugs found by Jann Horn.
Last patch is a minor samples fix spotted during the testing.

Alexei Starovoitov (3):
  bpf: fix refcnt overflow
  bpf: fix check_map_func_compatibility logic
  samples/bpf: fix trace_output example

 include/linux/bpf.h             |  3 +-
 kernel/bpf/inode.c              |  7 ++--
 kernel/bpf/syscall.c            | 24 ++++++++++---
 kernel/bpf/verifier.c           | 76 +++++++++++++++++++++++++----------------
 samples/bpf/trace_output_kern.c |  1 -
 5 files changed, 73 insertions(+), 38 deletions(-)

-- 
2.8.0
