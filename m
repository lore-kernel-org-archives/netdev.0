From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 0/5] Fix -Wunused-but-set-variable in ath10k/
Date: Thu, 24 Nov 2016 00:01:06 -0800
Message-ID: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Raja Mani <rmani@qti.qualcomm.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34400 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755116AbcKXIDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 03:03:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is part of the effort led by Arnd Bergmann to clean up
warnings in the kernel. This and following patchsets will focus on
"-Wunused-but-set-variable" as it among the noisier ones. These were
found compiling with W=1.

Kirtika Ruchandani (5):
  ath10k: Remove unused 'buf_len' variable
  ath10k: Remove unused 'num_vdev_stats' variable
  ath10k: Remove unused wmi_p2p_noa_descriptor 'noa' in wmi-tlv
  ath10k: Removed unused 'dev' in ath10k_ahb_clock_enable()
  ath10k: Removed unused 'dev' in ath10k_ahb_resource_init

 drivers/net/wireless/ath/ath10k/ahb.c     |  5 -----
 drivers/net/wireless/ath/ath10k/wmi-tlv.c |  2 --
 drivers/net/wireless/ath/ath10k/wmi.c     | 14 ++------------
 3 files changed, 2 insertions(+), 19 deletions(-)
