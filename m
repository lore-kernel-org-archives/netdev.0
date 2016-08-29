From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 0/2] Add matchall support to tc
Date: Mon, 29 Aug 2016 21:00:59 +0200
Message-ID: <1472497261-2881-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, yotamg@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32813 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755136AbcH2TBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 15:01:04 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so13789wme.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 12:01:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:
Add the matchall classifier support to tc and added the specific man pages.

---
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
