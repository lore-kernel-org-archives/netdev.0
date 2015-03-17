From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 0/2] tc class names: Ignore if default file does not exist
Date: Tue, 17 Mar 2015 22:15:40 +0200
Message-ID: <1426623342-16470-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:35371 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbCQU12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 16:27:28 -0400
Received: by lbcgn8 with SMTP id gn8so15715360lbc.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 13:27:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Split lib/names.c:db_names_alloc to 2 funcs for
    allocate and load names from file. Also added checking for malloc
    failing.

2) Ignore if default class names file does not exist if '-nm' option
    was specified, so it will be possible to create alias:

        alias tc='tc -nm'

    Changed default class name file cls_names -> tc_cls.

v2:
    Get rid of pointless 'ret' initialization
    in tc/tc_util.c - noticed by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Vadim Kochan (2):
  lib names: Split to db_names_alloc and db_names_load
  tc class: Ignore if default class name file does not exist

 include/names.h |  3 ++-
 lib/names.c     | 59 +++++++++++++++++++++++++++++++++++++++++----------------
 tc/tc_util.c    | 19 +++++++++++++++----
 3 files changed, 60 insertions(+), 21 deletions(-)

-- 
2.3.1
