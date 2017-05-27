From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2 0/4] ip: Add vrf show commmand
Date: Sat, 27 May 2017 17:34:46 -0600
Message-ID: <20170527233450.58015-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32972 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdE0Xez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:34:55 -0400
Received: by mail-pf0-f173.google.com with SMTP id e193so32376558pfh.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 16:34:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor ip address to export its capability to save a list of nlmsg's
for links and its link filter. Use both to add an 'ip vrf show' command
to list all configured VRF with table id.

David Ahern (4):
  ip address: Export ip_linkaddr_list
  ip address: Move filter struct to ip_common.h
  ip address: Change print_linkinfo_brief to take filter as an input
  ip vrf: Add show command

 include/libnetlink.h |  10 ++++
 ip/ip_common.h       |  27 ++++++++-
 ip/ipaddress.c       | 144 +++++++++++++++++++++++-------------------------
 ip/iplink.c          |   2 +-
 ip/ipvrf.c           | 153 +++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-vrf.8    |  11 ++++
 6 files changed, 266 insertions(+), 81 deletions(-)

-- 
2.11.0 (Apple Git-81)
