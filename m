From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 0/3] tc: act_ife: handle IEEE IFE ethertype as default
Date: Mon, 28 Aug 2017 15:03:12 -0400
Message-ID: <20170828190315.26646-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35745 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH1TE2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:28 -0400
Received: by mail-io0-f196.google.com with SMTP id c18so1089786ioj.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:04:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series will introduce the IFE ethertype which is registered by
IEEE. If the netlink act_ife type netlink attribute is not given it will
use this value by default now.
At least it will introduce some UAPI testcases to check if the default type
is used if not specified and vice versa.

- Alex

Alexander Aring (3):
  if_ether: add forces ife lfb type
  act_ife: use registered ife_type as fallback
  tc-testing: add test for testing ife type

 include/uapi/linux/if_ether.h                      |  1 +
 net/sched/act_ife.c                                | 17 ++------
 .../tc-testing/tc-tests/actions/tests.json         | 50 ++++++++++++++++++++++
 3 files changed, 54 insertions(+), 14 deletions(-)

-- 
2.11.0
