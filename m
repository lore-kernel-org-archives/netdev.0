From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v2 0/5] iproute: ila and fou addition
Date: Thu, 4 Aug 2016 13:34:52 -0700
Message-ID: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <shemming@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26183 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759009AbcHDUfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 16:35:12 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u74KQ5dM004900
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2016 13:35:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 24m96d9mm0-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 13:35:10 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 ef4070d65a8211e689880002c991e86a-195f7af0 for <netdev@vger.kernel.org>;	Thu,
 04 Aug 2016 13:35:08 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch set includes:

- Allow configuring checksum mode for ila LWT (e.g. configure
  checksum neutral
- Configuration for performing ila translations using netfilter hook
- fou encapsulation for ip6tnl and gre6
- fou listener for IPv6

v2:
  - Style fixes
  - Replace occurences of RTA_DATA with rta_getattr_u*

Tom Herbert (5):
  ila: Support for checksum neutral translation
  ila: Support for configuring ila to use netfilter hook
  ip6tnl: Support for fou encapsulation
  gre6: Support for fou encapsulation
  fou: Allowing configuring IPv6 listener

 ip/Makefile           |   2 +-
 ip/ip.c               |   3 +-
 ip/ip_common.h        |   1 +
 ip/ipfou.c            |   9 +-
 ip/ipila.c            | 267 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.c |  58 ++++++++++-
 ip/link_gre.c         |   2 +-
 ip/link_gre6.c        | 101 +++++++++++++++++++
 ip/link_ip6tnl.c      |  92 ++++++++++++++++-
 9 files changed, 527 insertions(+), 8 deletions(-)
 create mode 100644 ip/ipila.c

-- 
2.8.0.rc2
