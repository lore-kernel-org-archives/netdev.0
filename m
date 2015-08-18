From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/4] vrf: a few simplifications and cleanups
Date: Tue, 18 Aug 2015 20:28:00 +0300
Message-ID: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34385 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbbHRT3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:29:09 -0400
Received: by wicne3 with SMTP id ne3so108918598wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:29:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
These patches remove some unnecessary checks (patches 3, 4), unnecessary
num_slaves member and refcnt manipulations which are already done by the
upper functions.

Cheers,
 Nik

Nikolay Aleksandrov (4):
  vrf: drop unnecessary dev refcnt changes
  vrf: drop unused num_slaves member
  vrf: don't check for dstats and rth in uninit path
  vrf: simplify the netdev notifier function

 drivers/net/vrf.c | 15 ++++-----------
 include/net/vrf.h |  1 -
 2 files changed, 4 insertions(+), 12 deletions(-)

-- 
2.4.3
