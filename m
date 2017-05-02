From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2 0/3] ip: Initial support for extack errors
Date: Mon,  1 May 2017 20:18:22 -0700
Message-ID: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jakub.kicinski@netronome.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35099 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbdEBDSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:18:30 -0400
Received: by mail-pf0-f182.google.com with SMTP id v14so82507184pfd.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 20:18:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new function, rtnl_ack_extack, to allow commands to flip
to the new error reporting over time.

Convert iplink_modify to use the new function to display error strings
returned from ip link set commands.

David Ahern (3):
  netlink: import netlink message parsing from kernel
  netlink: Add support for extended ack to rtnl_talk
  ip link: Add extack handling for setlink

 include/libnetlink.h |  14 +++++
 include/nlattr.h     | 162 +++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iplink.c          |  18 +++++-
 lib/Makefile         |   2 +-
 lib/libnetlink.c     |  96 ++++++++++++++++++++++++++----
 lib/nlattr.c         | 145 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 423 insertions(+), 14 deletions(-)
 create mode 100644 include/nlattr.h
 create mode 100644 lib/nlattr.c

-- 
2.1.4
