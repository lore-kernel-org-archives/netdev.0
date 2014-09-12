From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 0/2] bridge: Two small fixes to vlan filtering code.
Date: Fri, 12 Sep 2014 16:26:15 -0400
Message-ID: <1410553577-17519-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:57552 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbaILU0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:26:32 -0400
Received: by mail-qa0-f50.google.com with SMTP id dc16so1301125qab.23
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:26:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series corrects 2 small issues that I've ran across recently
while doing more work with vlan filtering changes.

Thanks
-vlad

Vlad Yasevich (1):
  bridge: Check if vlan filtering is enabled only once.
  bridge: Allow clearing of pvid and untagged bitmap

 net/bridge/br_private.h |  3 +++
 net/bridge/br_vlan.c    | 18 ++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

-- 
1.9.3
