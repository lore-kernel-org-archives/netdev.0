From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 0/2] ip rule: merger iprule_flush and add selector support
Date: Thu, 22 Sep 2016 14:28:47 +0800
Message-ID: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35438 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcIVG3H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:29:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id 6so3349755pfl.2
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 23:29:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When merge iprule_flush() and iprule_list_or_save(). Renamed
rtnl_filter_t filter to filter_fn because we want to use global
variable 'filter' to filter nlmsg in the next patch.

Hangbin Liu (2):
  ip rule: merge ip rule flush and list, save together
  ip rule: add selector support

 ip/iprule.c        | 295 +++++++++++++++++++++++++++++++++++++++++------------
 man/man8/ip-rule.8 |   6 +-
 2 files changed, 231 insertions(+), 70 deletions(-)

-- 
2.5.5
