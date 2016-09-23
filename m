From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 0/2] ip rule: merger iprule_flush and add selector support
Date: Fri, 23 Sep 2016 11:25:53 +0800
Message-ID: <1474601155-28171-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34470 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932633AbcIWD0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 23:26:09 -0400
Received: by mail-pf0-f193.google.com with SMTP id 21so4593218pfy.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 20:26:09 -0700 (PDT)
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
