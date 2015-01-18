From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/3] Unify output for inet sockets
Date: Sun, 18 Jan 2015 22:43:32 +0200
Message-ID: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44695 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbARUyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 15:54:10 -0500
Received: by mail-wi0-f174.google.com with SMTP id n3so11624439wiv.1
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 12:54:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is series is about to have output information from /proc and
Netlink in one place.

Some short summary:

    1) Make memory info more readable.
    2) Unify output of inet sockets from /proc and Netlink.
    3) Added new '-H, --human' option to show info in more human format
        which is used for memory info meanwhile.

Vadim Kochan (3):
  ss: Make meminfo look little bit more readable
  ss: Unify inet sockets output
  ss: Unify tcp stats output

 include/utils.h |   3 +
 ip/ipaddress.c  |  31 +--
 lib/utils.c     |  40 ++-
 misc/ss.c       | 737 ++++++++++++++++++++++++++++++--------------------------
 4 files changed, 437 insertions(+), 374 deletions(-)

-- 
2.1.3
