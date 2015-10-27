From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/2] mpls: mulipath improvements
Date: Tue, 27 Oct 2015 00:37:34 +0000
Message-ID: <1445906256-14927-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:64663 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789AbbJ0AiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 20:38:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two improvements to the recently added mpls multipath support. The
first is a fix for missing initialisation the nexthop address length
for the v4 and v6 explicit null label routes, and the second is to
reduce the amount of memory used by mpls routes by changing the way
the via addresses are stored.

Robert Shearman (2):
  mpls: fix forwarding using v4/v6 explicit null
  mpls: reduce memory usage of routes

 net/mpls/af_mpls.c  | 123 +++++++++++++++++++++++++++++++++++++---------------
 net/mpls/internal.h |  26 ++++++++++-
 2 files changed, 112 insertions(+), 37 deletions(-)

-- 
2.1.4
