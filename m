From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 v2 0/4] Fix ip segfault when using --color switch
Date: Fri, 13 Oct 2017 15:57:15 +0200
Message-ID: <20171013135719.18450-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:55422 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbdJMN5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:57:30 -0400
Received: by mail-wr0-f182.google.com with SMTP id 22so1117269wrb.12
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:57:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I cleanup code not to use magic offsets. I kept it in separate commits,
as it's clearer what happened.

Petr Vorel (4):
  color: Fix ip segfault when using --color switch
  color: Fix another ip segfault when using --color switch
  color: Cleanup code to remove "magic" offset + 7
  color: Rename enum

 include/color.h      |  3 +--
 include/json_print.h |  2 +-
 lib/color.c          | 17 ++++++++++-------
 3 files changed, 12 insertions(+), 10 deletions(-)

-- 
2.14.2
