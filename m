From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 0/6] ip: add save/restore to xfrm tables
Date: Fri,  2 Sep 2016 12:02:20 +0300
Message-ID: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14498 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752320AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Tikhomirov (6):
  ip: merge together all save_xxx_preps and xxx_dump_check_magics
  ip: merge together all save_xxx to save_nlmsg
  ip xfrm state: add save/restore
  ip xfrm policy: add save/restore
  ip xfrm state: fixup hard/soft timeouts/limits while save
  ip xfrm policy: fixup hard/soft timeouts/limits while save

 ip/ip_common.h     |  10 ++++
 ip/ipaddress.c     |  57 ++--------------------
 ip/iproute.c       |  41 +++++++++-------
 ip/iprule.c        |  58 ++--------------------
 ip/xfrm_policy.c   | 104 ++++++++++++++++++++++++++++++++++++++--
 ip/xfrm_state.c    | 138 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-xfrm.8 |  24 ++++++++++
 7 files changed, 296 insertions(+), 136 deletions(-)

-- 
2.5.5
