From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/2] ss: Implement sctp_diag support
Date: Wed,  9 Nov 2016 12:12:22 +0100
Message-ID: <20161109111224.3946-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46233 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933767AbcKILMg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 06:12:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version two of SCTP support in ss patch set. With only minor
changes from v1, it is rather a resubmit to draw people's attention.

The changes from v1 are:
- Patch 1 adds linux/sctp.h after proper extraction from kernel UAPI
  headers (although it didn't change due to that), patch description
  updated accordingly.
- Patch 2 also adds the new flag to ss man page.

Phil Sutter (2):
  include: Add linux/sctp.h
  ss: Add support for SCTP protocol

 include/linux/sctp.h | 1005 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ss.8        |    3 +
 misc/ss.c            |  212 ++++++++++-
 3 files changed, 1212 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/sctp.h

-- 
2.10.0
