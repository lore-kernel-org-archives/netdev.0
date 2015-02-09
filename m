From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 0/2] IPv6 Fix 2 small issues with UFO restoration code
Date: Mon,  9 Feb 2015 09:38:19 -0500
Message-ID: <1423492701-21429-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:40240 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932902AbbBIOib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 09:38:31 -0500
Received: by mail-qa0-f44.google.com with SMTP id w8so21224989qac.3
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 06:38:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes 2 small issues introduced by the
"Restore UFO support to virtio_net devices" series.

Thanks.

V2:  Fixed patch title and description for patch1.

Vladislav Yasevich (2):
  ipv6: Resolve sparce error with fragment id selection
  ipv6: Make __ipv6_select_ident static

 include/net/ipv6.h     | 2 --
 net/ipv6/output_core.c | 5 +++--
 2 files changed, 3 insertions(+), 4 deletions(-)

-- 
1.9.3
