From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next 0/2] Extract IFE logic to module
Date: Tue, 31 Jan 2017 15:57:02 +0200
Message-ID: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com, idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34620 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752411AbdAaOVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 09:21:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract ife logic from the tc_ife action into an independent module, and
make the tc_ife action use it. This way, the ife encapsulation can be used
by other modules other than tc_ife action.

Yotam Gigi (2):
  net: Introduce ife encapsulation module
  net/sched: act_ife: Change to use ife module

 MAINTAINERS                        |   7 ++
 include/net/ife.h                  |  51 +++++++++++++
 include/net/tc_act/tc_ife.h        |   3 -
 include/uapi/linux/Kbuild          |   1 +
 include/uapi/linux/ife.h           |  18 +++++
 include/uapi/linux/tc_act/tc_ife.h |  10 +--
 net/Kconfig                        |   1 +
 net/Makefile                       |   1 +
 net/ife/Kconfig                    |  16 +++++
 net/ife/Makefile                   |   5 ++
 net/ife/ife.c                      | 142 +++++++++++++++++++++++++++++++++++++
 net/sched/Kconfig                  |   1 +
 net/sched/act_ife.c                | 110 +++++++++-------------------
 13 files changed, 276 insertions(+), 90 deletions(-)
 create mode 100644 include/net/ife.h
 create mode 100644 include/uapi/linux/ife.h
 create mode 100644 net/ife/Kconfig
 create mode 100644 net/ife/Makefile
 create mode 100644 net/ife/ife.c

-- 
2.4.11
