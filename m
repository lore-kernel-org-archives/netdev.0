From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] ipv4: fib: FIB notifications cleanup
Date: Fri, 10 Mar 2017 08:56:17 +0100
Message-ID: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36005 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdCJH4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:56:23 -0500
Received: by mail-wr0-f195.google.com with SMTP id l37so10529080wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:56:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The first patch moves the core FIB notification code to a separate file,
so that code related to FIB rules is placed in fib_rules.c and not
fib_trie.c. The reason for the change will become even more apparent in
follow-up patchset where we extend the FIB rules notifications.

Second patch removes a redundant argument.

Ido Schimmel (2):
  ipv4: fib: Move FIB notification code to a separate file
  ipv4: fib: Remove redundant argument

 include/net/ip_fib.h    |  12 ++++++
 net/ipv4/Makefile       |   2 +-
 net/ipv4/fib_notifier.c |  86 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/fib_rules.c    |   8 ++++
 net/ipv4/fib_trie.c     | 108 +++---------------------------------------------
 5 files changed, 113 insertions(+), 103 deletions(-)
 create mode 100644 net/ipv4/fib_notifier.c

-- 
2.7.4
