From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute 0/5] iproute: ila and fou additions
Date: Thu, 14 Jul 2016 12:22:11 -0700
Message-ID: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>,
	Tom Herbert <tom@herbertland.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50981 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751160AbcGNTW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:22:26 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u6EJJFDV015597
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 246grf0108-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:25 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 4a652fc449f811e6974124be0593f280-a51fdaf0 for <netdev@vger.kernel.org>;	Thu,
 14 Jul 2016 12:22:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch set includes:

- Allow configuring checksum mode for ila LWT (e.g. configure
  checksum neutral
- Configuration for performing ila translations using netfilter hook
- fou encapsulation for ip6tnl and gre6
- fou listener for IPv6

*** SUBJECT HERE ***

*** BLURB HERE ***

Tom Herbert (5):
  ila: Support for checksum neutral translation
  ila: Support for configuring ila to use netfilter hook
  ip6tnl: Support for fou encapsulation
  gre6: Support for fou encapsulation
  fou: Allowing configuring IPv6 listener

 ip/Makefile           |   2 +-
 ip/ip.c               |   3 +-
 ip/ip_common.h        |   1 +
 ip/ipfou.c            |   8 +-
 ip/ipila.c            | 259 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.c |  57 ++++++++++-
 ip/link_gre6.c        | 101 ++++++++++++++++++++
 ip/link_ip6tnl.c      |  92 +++++++++++++++++-
 8 files changed, 516 insertions(+), 7 deletions(-)
 create mode 100644 ip/ipila.c

-- 
2.8.0.rc2
