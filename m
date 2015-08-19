From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/4] vrf: cleanups part 2
Date: Wed, 19 Aug 2015 06:27:06 +0300
Message-ID: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34495 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbbHSPAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:00:47 -0400
Received: by wicne3 with SMTP id ne3so129424923wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:00:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This is the next part of vrf cleanups, patch 1 drops the SLAB_PANIC when
creating kmem cache since it's handled, patch 02 removes a slave duplicate
check which is already done by the lower/upper code, patch 3 moves the
ndo_add_slave code around a bit so we can drop an error label and patch 4
drops the master device checks which are unnecessary because the ops are
taken from the master device itself so it can't be different.

Cheers,
 Nik

Nikolay Aleksandrov (4):
  vrf: don't panic on cache create failure
  vrf: remove unnecessary duplicate check
  vrf: move vrf_insert_slave so we can drop a goto label
  vrf: ndo_add|del_slave drop unnecessary checks

 drivers/net/vrf.c | 24 ++++--------------------
 1 file changed, 4 insertions(+), 20 deletions(-)

-- 
2.4.3
