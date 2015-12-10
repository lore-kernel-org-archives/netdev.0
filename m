From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 0/4] mpls: fixes for nexthops without via addresses
Date: Thu, 10 Dec 2015 19:30:47 +0000
Message-ID: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sam.h.russell@gmail.com>, Robert Shearman <rshearma@brocade.com>
To: <ebiederm@xmission.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:44974 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750888AbbLJTbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 14:31:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These four fixes all apply to the case of having an mpls route with an
output device, but without a nexthop.

Patches 2 and 3 could really have been combined in one patch, but I
wanted to separate the fix for some recent breakage from the fix for a
day-1 issue.

Robert Shearman (4):
  mpls: validate L2 via address length
  mpls: don't dump RTA_VIA attribute if not specified
  mpls: fix out-of-bounds access when via address not specified
  mpls: make via address optional for multipath routes

 net/mpls/af_mpls.c | 43 +++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

-- 
2.1.4
