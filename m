From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v2 0/2] tcp: add NV congestion control
Date: Wed, 8 Jun 2016 21:16:43 -0700
Message-ID: <1465445805-2521783-1-git-send-email-brakmo@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:7063 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752491AbcFIERE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:17:04 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u594Dgj1011050
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2016 21:17:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 23e37tq0ym-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:17:02 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 02d8dc702df911e6ae0b0002c95209d8-29bfd2e0 for <netdev@vger.kernel.org>;	Wed,
 08 Jun 2016 21:17:00 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed most of the module parameters

Tested in a rack using between 1 and 380 active TCP-NV flows.

Consists of the following patches:
[PATCH net-next v2 1/2] tcp: add in_flight to tcp_skb_cb
[PATCH net-next v2 2/2] tcp: add NV congestion control

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

 include/net/tcp.h     |   2 +
 net/ipv4/Kconfig      |  16 ++
 net/ipv4/Makefile     |   1 +
 net/ipv4/tcp_input.c  |   5 +-
 net/ipv4/tcp_nv.c     | 476 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   4 +-
 6 files changed, 502 insertions(+), 2 deletions(-)
