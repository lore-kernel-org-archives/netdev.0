From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 0/2] ila: Precompute checksums
Date: Thu, 20 Aug 2015 11:22:36 -0700
Message-ID: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:12384 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752244AbbHTSWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 14:22:49 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7KIJn0a014518
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 11:22:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wdh2u0h8r-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 11:22:48 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 74143650476811e5bde424be0595f910-6e7f32b0 for <netdev@vger.kernel.org>;	Thu,
 20 Aug 2015 11:22:45 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set:
 - Adds argument ot LWT build_state that holds a pointer to the fib
   configuration being applied to the new route
 - Adds support in ILA to precompute checksum difference for
   performance optimization

v2:
 Move return argument in build_state to end of arguments

Tom Herbert (2):
  lwt: Add cfg argumnt to build_state
  ila: Precompute checksum difference for translations

 include/net/lwtunnel.h    |  5 ++++-
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 15 +++++++++------
 net/ipv4/ip_tunnel_core.c |  1 +
 net/ipv6/ila.c            | 19 +++++++++++++++++++
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  1 +
 7 files changed, 39 insertions(+), 10 deletions(-)

-- 
1.8.1
