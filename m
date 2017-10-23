From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/7] ipv6: addrconf: hash improvements and cleanups
Date: Mon, 23 Oct 2017 16:17:44 -0700
Message-ID: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:49478 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJWXR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:17:56 -0400
Received: by mail-io0-f194.google.com with SMTP id n137so21965995iod.6
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:17:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unecessary BH blocking, and bring IPv6 addrconf to modern world,
with per netns hash perturbation and decent hash size.

Eric Dumazet (7):
  ipv6: addrconf: move ipv6_chk_same_addr() to avoid forward declaration
  ipv6: addrconf: factorize inet6_addr_hash() call
  ipv6: addrconf: add per netns perturbation in inet6_addr_hash()
  ipv6: addrconf: do not block BH in ipv6_chk_addr_and_flags()
  ipv6: addrconf: do not block BH in ipv6_get_ifaddr()
  ipv6: addrconf: do not block BH in /proc/net/if_inet6 handling
  ipv6: addrconf: do not block BH in ipv6_chk_home_addr()

 include/net/addrconf.h |  2 +-
 net/ipv6/addrconf.c    | 94 ++++++++++++++++++++++++--------------------------
 2 files changed, 46 insertions(+), 50 deletions(-)

-- 
2.15.0.rc0.271.g36b669edcc-goog
