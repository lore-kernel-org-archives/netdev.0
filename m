From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/2] bpf: verifier fixes
Date: Thu, 19 May 2016 18:17:12 -0700
Message-ID: <1463707034-2372430-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39699 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754063AbcETBRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 21:17:18 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4K1ETTc008468
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 231agk7048-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:17 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 96a25a661e2811e689400002c991e86a-d58dfc50 for <netdev@vger.kernel.org>;	Thu,
 19 May 2016 18:17:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further testing of 'direct packet access' uncovered
several usability issues. Fix them.

Alexei Starovoitov (2):
  bpf: support decreasing order in direct packet access
  bpf: teach verifier to recognize imm += ptr pattern

 kernel/bpf/verifier.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

-- 
2.8.0
