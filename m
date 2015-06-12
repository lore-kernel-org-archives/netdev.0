From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] flow_dissector: Fix MPLS parsing and add ext hdr support
Date: Fri, 12 Jun 2015 09:01:04 -0700
Message-ID: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:22283 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751700AbbFLQBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:01:21 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5CG0Iec017022
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1uynu712ww-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:21 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 43ce5598111c11e5a4310002c9931860-238d42a0 for <netdev@vger.kernel.org>;	Fri,
 12 Jun 2015 09:01:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to shift label. Added parsing of dst, hop-by-hop, and routing
extension headers.


Tom Herbert (2):
  flow_dissector: Fix MPLS entropy label handling in flow dissector
  flow_dissector: add support for dst, hop-by-hop and routing ext hdrs

 net/core/flow_dissector.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

-- 
1.8.1
