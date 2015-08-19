From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] ila: Precompute checksums
Date: Tue, 18 Aug 2015 20:21:09 -0700
Message-ID: <1439954471-599831-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <roopa@cumulusnetworks.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60343 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbbHSDVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 23:21:23 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7J3LASK026195
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 20:21:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wc1awapqk-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 20:21:22 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 5c30e080462111e5ba6124be05956610-59bf82b0 for <netdev@vger.kernel.org>;	Tue,
 18 Aug 2015 20:21:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set:
 - Adds argument ot LWT build_state that holds a pointer to the fib
   configuration being applied to the new route
 - Adds support in ILA to precompute checksum difference for
   performance optimization

Tom Herbert (2):
  lwt: Add cfg argumnt to build_state
  ila: Precompute checksum difference for translations

 include/net/lwtunnel.h    |  9 ++++++---
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 14 +++++++++-----
 net/ipv4/ip_tunnel_core.c |  3 ++-
 net/ipv6/ila.c            | 21 ++++++++++++++++++++-
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  3 ++-
 7 files changed, 44 insertions(+), 14 deletions(-)

-- 
1.8.1
