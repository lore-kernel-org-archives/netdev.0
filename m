From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2 0/3] uapi: add kbuild for some files
Date: Fri,  2 Dec 2016 14:53:57 -0800
Message-ID: <20161202225400.32751-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33325 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752292AbcLBWyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:54:03 -0500
Received: by mail-pf0-f177.google.com with SMTP id d2so54796131pfd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:54:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some files which are in uapi but not being copied
by make headers_install

Stephen Hemminger (3):
  tc: export tunnel key file
  uapi: export tc_skbmod.h
  uapi: export nf_log.h

 include/uapi/linux/netfilter/Kbuild | 1 +
 include/uapi/linux/tc_act/Kbuild    | 2 ++
 2 files changed, 3 insertions(+)

V2 - typo in s/sbkmod/skbmod/

-- 
2.10.2
