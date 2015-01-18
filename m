From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 0/3] ip netns: Run over all netns
Date: Sun, 18 Jan 2015 16:10:16 +0200
Message-ID: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:45009 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbAROUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 09:20:55 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so27332700wes.6
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 06:20:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.

'ip netns exec' executes command forcely on eacn nsname.

Added new '-all' 'ip' option to run over each netns,
it can be used for other utils as generic option.

v2:
   Use '-all' option instead of netns name 'all'.

Vadim Kochan (3):
  lib: Exec func on each netns
  ip netns: Allow exec on each netns
  ip netns: Delete all netns

 include/namespace.h |  6 ++++
 include/utils.h     |  5 +++
 ip/ip.c             |  5 ++-
 ip/ipnetns.c        | 98 ++++++++++++++++++++++++++++++++---------------------
 lib/namespace.c     | 22 ++++++++++++
 lib/utils.c         | 28 +++++++++++++++
 man/man8/ip-netns.8 | 28 ++++++++++++---
 man/man8/ip.8       |  7 +++-
 8 files changed, 153 insertions(+), 46 deletions(-)

-- 
2.1.3
