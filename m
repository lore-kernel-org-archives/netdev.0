From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 0/2] bpf fixes
Date: Wed, 15 Jun 2016 18:25:37 -0700
Message-ID: <1466040339-3756110-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Goldshtein <goldshtn@gmail.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:6334 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753256AbcFPBZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 21:25:42 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u5G1NjRF017866
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 23geabpqnh-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 3c5d0116336111e690410002c99293a0-333e0b00 for <netdev@vger.kernel.org>;	Wed,
 15 Jun 2016 18:25:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for two bpf bugs:
1st bug reported by Sasha Goldshtein here:
https://github.com/iovisor/bcc/issues/570
2nd discovered by Daniel Borkmann by manual code analysis.
See patches for details.

Alexei Starovoitov (2):
  bpf: fix matching of data/data_end in verifier
  bpf, trace: check event type in bpf_perf_event_read

 include/linux/bpf.h      | 28 +++++++++++++++++++++++++++-
 kernel/bpf/verifier.c    | 41 +++++++----------------------------------
 kernel/trace/bpf_trace.c | 10 ++++++++--
 net/core/filter.c        | 16 ++++++++++++++--
 4 files changed, 56 insertions(+), 39 deletions(-)

-- 
2.8.0
