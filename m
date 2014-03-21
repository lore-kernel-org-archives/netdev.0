From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 0/3] Altera TSE: Misc driver updates
Date: Thu, 20 Mar 2014 20:43:14 -0500
Message-ID: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:52556 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759424AbaCUBsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:48:00 -0400
Received: by mail-oa0-f42.google.com with SMTP id i4so1887157oah.15
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:47:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a version number to the driver's get regs routine invoked
by ethool, corrects an issue detected by the kbuild test robot, and
addresses a couple of minor typo errors.

Please apply this series.

Thank you

Vince 

Vince Bridgers (3):
  Altera TSE: Set version number by driver's get regs
  Altera TSE: Correct typecast issue detected by kbuild test robot
  Altera TSE: Correct two typos in original submission

 drivers/net/ethernet/altera/altera_sgdma.c       |   16 +++++++---------
 drivers/net/ethernet/altera/altera_tse_ethtool.c |    8 ++++++++
 2 files changed, 15 insertions(+), 9 deletions(-)

-- 
1.7.9.5
