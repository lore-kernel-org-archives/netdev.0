From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute2/net-next 0/3] Add the tc-sample action
Date: Sun,  5 Feb 2017 09:58:51 +0200
Message-ID: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55251 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751812AbdBEH4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 02:56:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the tc-sample action support and the corresponding man
page. More information about the action and its usage can be found in the
commit message.

Yotam Gigi (3):
  tc: Add support for the sample tc action
  tc: man: Add man entry for the tc-sample action
  tc: man: matchall: Update examples to include sample

 bash-completion/tc               |   8 +-
 include/linux/tc_act/tc_sample.h |  26 ++++++
 man/man8/Makefile                |   2 +-
 man/man8/tc-matchall.8           |  10 +++
 man/man8/tc-sample.8             | 125 ++++++++++++++++++++++++++
 tc/Makefile                      |   1 +
 tc/m_sample.c                    | 186 +++++++++++++++++++++++++++++++++++++++
 7 files changed, 356 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/tc_act/tc_sample.h
 create mode 100644 man/man8/tc-sample.8
 create mode 100644 tc/m_sample.c

-- 
2.4.11
