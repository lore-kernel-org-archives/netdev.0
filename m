From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 0/5] fou: some fixes and updates
Date: Fri, 10 Apr 2015 12:00:25 -0700
Message-ID: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33833 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbbDJTAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:00:41 -0400
Received: by pacyx8 with SMTP id yx8so29887361pac.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 12:00:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1~3 fix some minor bugs in net/ipv4/fou.c, the only
thing I am not sure is if it's too late to change the
byte order of FOU_ATTR_PORT, if so we have to fix iproute2
instead of kernel.

Patch 4~5 add some new features to make it complete.

v2: make fou->port be16 too

Cong Wang (5):
  fou: avoid calling udp_del_offload() twice
  fou: exit early when parsing config fails
  fou: always use be16 for port
  fou: add network namespace support
  fou: implement FOU_CMD_GET

 include/uapi/linux/fou.h |   1 +
 net/ipv4/fou.c           | 230 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 186 insertions(+), 45 deletions(-)

-- 
1.8.3.1
