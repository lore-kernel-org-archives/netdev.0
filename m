From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Wed,  7 Jan 2015 13:04:19 +0200
Message-ID: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:56101 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbAGLOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:14:48 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so876659lbv.11
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 03:14:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.

'ip netns exec' executes command forcely on eacn nsname.

Vadim Kochan (3):
  lib: Exec func on each netns
  ip netns: Allow exec on each netns
  ip netns: Delete all netns

 include/namespace.h |  6 ++++
 include/utils.h     |  5 +++
 ip/ipnetns.c        | 96 ++++++++++++++++++++++++++++++++---------------------
 lib/namespace.c     | 22 ++++++++++++
 lib/utils.c         | 28 ++++++++++++++++
 man/man8/ip-netns.8 | 26 ++++++++++++---
 6 files changed, 141 insertions(+), 42 deletions(-)

-- 
2.1.3
