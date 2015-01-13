From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] Refactoring for monitoring utils
Date: Tue, 13 Jan 2015 20:14:22 +0200
Message-ID: <1421172864-20853-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:51641 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbAMSYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:24:55 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so4031872lbv.12
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:24:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This series is just about refactoring for bridge/ip/rtmon monitoring tools.

Changes:
    1) Added #define for nlmsg_type = 15 which is used for log timestamp within
        nlmsg for monitoring tools.

    2) Using one function to print timestamp from nlmsg for ip/bridge monitor tools.

Vadim Kochan (2):
  Add define for nlmsg_types with timestamp
  Use one func to print timestamp from nlmsg

 bridge/monitor.c     | 18 +++---------------
 include/libnetlink.h |  4 ++++
 include/utils.h      |  2 ++
 ip/ipmonitor.c       |  9 ++-------
 ip/rtmon.c           |  2 +-
 lib/utils.c          | 10 ++++++++++
 6 files changed, 22 insertions(+), 23 deletions(-)

-- 
2.1.3
