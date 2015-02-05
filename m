From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 0/2] IPv6 Fix 2 small issues with UFO restoration code
Date: Thu,  5 Feb 2015 09:41:35 -0500
Message-ID: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:43736 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbbBEOlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:41:44 -0500
Received: by mail-qc0-f179.google.com with SMTP id w7so6600003qcr.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:41:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes 2 small issues introduced by the
"Restore UFO support to virtio_net devices" series.

Thanks.

Vladislav Yasevich (2):
  ipv6: Resolve sparce error with fragment id selection
  ipv6: Make __ipv6_select_ident static

 include/net/ipv6.h     | 2 --
 net/ipv6/output_core.c | 5 +++--
 2 files changed, 3 insertions(+), 4 deletions(-)

-- 
1.9.3
