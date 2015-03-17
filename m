From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] tc class names: Ignore if default file does not exist
Date: Tue, 17 Mar 2015 18:52:02 +0200
Message-ID: <1426611124-2295-1-git-send-email-vadim4j@gmail.com>
Cc: daniel@iogearbox.net, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:36107 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbbCQRDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 13:03:52 -0400
Received: by lamx15 with SMTP id x15so14261167lam.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 10:03:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Split lib/names.c:db_names_alloc to 2 funcs for
    allocate and load names from file. Also added checking for malloc
    failing.

2) Ignore if default class names file does not exist if '-nm' option
    was specified, so it will be possible to create alias:

        alias tc='tc -nm'

    Changed default class name file cls_names -> tc_cls.

Vadim Kochan (2):
  lib names: Split to db_names_alloc and db_names_load
  tc class: Ignore if default class name file does not exist

 include/names.h |  3 ++-
 lib/names.c     | 59 +++++++++++++++++++++++++++++++++++++++++----------------
 tc/tc_util.c    | 19 +++++++++++++++----
 3 files changed, 60 insertions(+), 21 deletions(-)

-- 
2.3.1
