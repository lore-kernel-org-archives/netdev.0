From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] strp: Minor fixes to strparser and kcm
Date: Tue, 23 Aug 2016 11:55:29 -0700
Message-ID: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19038 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754601AbcHWTOy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 15:14:54 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7NIrZSB010342
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 250dxfvw5r-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:41 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 2ddd9a5a696311e681c324be0593f280-718f1aa0 for <netdev@vger.kernel.org>;        Tue,
 23 Aug 2016 11:55:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix locking issue in kcm and losing events when paused.

Tom Herbert (2):
  strparser: Queue work when being unpaused
  kcm: Fix locking issue

 include/net/strparser.h   |  5 +----
 net/kcm/kcmproc.c         | 20 +++++++++++++++-----
 net/kcm/kcmsock.c         | 13 ++++++++-----
 net/strparser/strparser.c | 11 +++++++++++
 4 files changed, 35 insertions(+), 14 deletions(-)

-- 
2.8.0.rc2
