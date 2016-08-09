From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v3 0/5] iproute: ila and fou additions
Date: Tue, 9 Aug 2016 14:41:34 -0700
Message-ID: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50974 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932497AbcHIVlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:41:44 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u79LZl4F011746
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 14:41:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24qmgjgych-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:41:43 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 100b85b25e7a11e687910002c9931860-458caaf0 for <netdev@vger.kernel.org>;	Tue,
 09 Aug 2016 14:41:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch set includes:

- Allow configuring checksum mode for ila LWT (e.g. configure
  checksum neutral
- Configuration for performing ila translations using netfilter hook
- fou encapsulation for ip6tnl and gre6
- fou listener for IPv6

v2:
  - Fixed coding style issues

v3:
  - Fixed uniinitialized variable waning in ipila.c


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
 ip/ipila.c            | 268 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.c |  58 ++++++++++-
 ip/link_gre.c         |   2 +-
 ip/link_gre6.c        | 101 +++++++++++++++++++
 ip/link_ip6tnl.c      |  92 ++++++++++++++++-
 9 files changed, 528 insertions(+), 8 deletions(-)
 create mode 100644 ip/ipila.c

-- 
2.8.0.rc2
