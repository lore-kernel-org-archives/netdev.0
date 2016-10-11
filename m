From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 0/9] Cleanup backlog
Date: Tue, 11 Oct 2016 07:00:39 -0400
Message-ID: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34758 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbcJKLJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:09:12 -0400
Received: by mail-io0-f181.google.com with SMTP id r30so20843308ioi.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 04:09:12 -0700 (PDT)
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
 tc/m_gact.c                   |   4 +-
 tc/m_ife.c                    |  38 ++++--
 tc/m_skbmod.c                 | 260 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 319 insertions(+), 17 deletions(-)
 create mode 100644 tc/m_skbmod.c

-- 
1.9.1
