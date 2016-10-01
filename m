From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 0/9] Cleanup backlog
Date: Sat,  1 Oct 2016 16:48:28 -0400
Message-ID: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34479 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pf0-f193.google.com with SMTP id 190so713539pfv.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Variety of cleanup and new functionality I had sitting around on my
private tree

Craig Dillabaugh (1):
  action gact: list pipe as a valid action

Jamal Hadi Salim (3):
  actions ife: Introduce encoding and decoding of tcindex metadata
  actions:  add skbmod action
  man pages: Add tc-ife to Makefile

Lucas Bates (2):
  man pages: update ife action to include tcindex
  man pages: add man page for skbmod action

Roman Mashak (3):
  ife action: allow specifying index in hex
  ife: print prio, mark and hash as unsigned
  ife: improve help text

 include/linux/tc_act/tc_ife.h |   3 +-
 man/man8/Makefile             |   2 +-
 man/man8/tc-ife.8             |  29 ++++-
 man/man8/tc-skbmod.8          | 137 +++++++++++++++++++++
 tc/Makefile                   |   1 +
 tc/m_gact.c                   |   4 +-
 tc/m_ife.c                    |  38 ++++--
 tc/m_skbmod.c                 | 270 ++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 467 insertions(+), 17 deletions(-)
 create mode 100644 man/man8/tc-skbmod.8
 create mode 100644 tc/m_skbmod.c

-- 
1.9.1
