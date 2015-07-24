From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2 0/2] ipv6: Avoid rt6_probe() taking writer lock in the fast path
Date: Fri, 24 Jul 2015 09:57:41 -0700
Message-ID: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:3887 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753084AbbGXQ6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 12:58:00 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6OGvYQ1004312
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vus6jr1g5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:59 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 217c4f8e322511e5a14324be0593f280-d87f42b0 for <netdev@vger.kernel.org>;	Fri,
 24 Jul 2015 09:57:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:
1. Separate the code re-arrangement into another patch
2. Fix style
