From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 0/2] tcp: add NV congestion control
Date: Tue, 17 May 2016 18:25:34 -0700
Message-ID: <1463534736-2739015-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:28087 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596AbcERB0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 21:26:01 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4I1LPjZ010480
	for <netdev@vger.kernel.org>; Tue, 17 May 2016 18:26:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 230e0gr5ds-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 May 2016 18:26:00 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 786e709e1c9711e6840624be0595f910-cb8c3c50 for <netdev@vger.kernel.org>;	Tue,
 17 May 2016 18:25:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for NV congestion control.

This version of NV does much better than previous versions when things are
very congested. 

Tested in a rack using between 1 and 380 active TCP-NV flows.

Consists of the following patches:
[PATCH net-next 1/2] tcp: add in_flight to tcp_skb_cb
[PATCH net-next 2/2] tcp: add NV congestion control

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

include/net/tcp.h     |   2 +
net/ipv4/Kconfig      |  16 ++
net/ipv4/Makefile     |   1 +
net/ipv4/tcp_input.c  |   6 +-
net/ipv4/tcp_nv.c     | 592 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
net/ipv4/tcp_output.c |   4 +-
6 files changed, 619 insertions(+), 2 deletions(-)
