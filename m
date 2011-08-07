From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/2] ptp: bug fixes for 3.1 and 3.0
Date: Sun,  7 Aug 2011 09:03:02 +0200
Message-ID: <cover.1312699693.git.richard.cochran@omicron.at>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57984 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab1HGHCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 03:02:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches fix two bugs in the PTP Hardware Clock drivers. The
drivers were first introduced in Linux version 3.0.

Please apply them.

Thanks,
Richard


Richard Cochran (2):
  gianfar: fix fiper alignment after resetting the time
  dp83640: increase receive time stamp buffer size

 drivers/net/gianfar_ptp.c |    9 ++-------
 drivers/net/phy/dp83640.c |    5 ++---
 2 files changed, 4 insertions(+), 10 deletions(-)

