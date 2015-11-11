From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 0/3] ipv6: Fixes for pmtu update and DST_NOCACHE route
Date: Wed, 11 Nov 2015 11:51:05 -0800
Message-ID: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55019 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbbKKTvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:51:20 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tABJlKOG000591
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1y1e06qcnu-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:19 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 92f0c08a88ad11e5b24a0002c95209d8-25bfd230 for <netdev@vger.kernel.org>;	Wed,
 11 Nov 2015 11:51:18 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes:
1. An oops during IPv6 pmtu update on a IPv4 GRE running
   in an IPSec setup
2. Misc fixes on DST_NOCACHE route
