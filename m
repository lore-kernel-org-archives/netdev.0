From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v3 0/2] Add matchall support to tc
Date: Wed, 31 Aug 2016 09:28:25 +0200
Message-ID: <1472628507-1991-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, yotamg@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36768 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756107AbcHaH2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 03:28:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so6205596wmf.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 00:28:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:
Add the matchall classifier support to tc and added the specific man pages.

---
v2->v3:
-fixed couple of typos in man pages
v1->v2:
-fixed couple of checkpatch issues

Yotam Gigi (2):
  tc: Add support for the matchall traffic classifier.
  tc: man: Add man entry for the matchall classifier.

 man/man8/Makefile      |   2 +-
 man/man8/tc-matchall.8 |  76 ++++++++++++++++++++++++++
 man/man8/tc.8          |   5 ++
 tc/Makefile            |   1 +
 tc/f_matchall.c        | 143 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 226 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-matchall.8
 create mode 100644 tc/f_matchall.c

-- 
2.5.5
