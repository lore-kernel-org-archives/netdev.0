From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 0/2] Fix IFE meta modules loading
Date: Wed, 11 Oct 2017 10:50:28 -0400
Message-ID: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:51522 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdJKOuu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 10:50:50 -0400
Received: by mail-it0-f67.google.com with SMTP id o135so3164700itb.0
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:50:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust module alias names of IFE meta modules and fix the bug that
prevented auto-loading IFE modules in run-time.

Roman Mashak (2):
  net sched actions: change IFE modules alias names
  net sched actions: fix module auto-loading

 include/net/tc_act/tc_ife.h     |  2 +-
 net/sched/act_ife.c             | 16 +++++++++++++++-
 net/sched/act_meta_mark.c       |  2 +-
 net/sched/act_meta_skbprio.c    |  2 +-
 net/sched/act_meta_skbtcindex.c |  2 +-
 5 files changed, 19 insertions(+), 5 deletions(-)

-- 
1.9.1
