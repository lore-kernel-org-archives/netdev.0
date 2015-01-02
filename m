From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 0/7] Fixing the "Time Counter fixes and improvements"
Date: Fri,  2 Jan 2015 20:22:02 +0100
Message-ID: <cover.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:52247 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbABTWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:14 -0500
Received: by mail-we0-f178.google.com with SMTP id p10so4868723wes.37
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:12 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

For this series I had only tested the build with ARCH=x86 and arm, but
others like sparc64, microblaze, powerpc, and s390 will fail because
they somehow don't indirectly include clocksource.h for the drivers in
question.

This series fixes the build issues reported by:
 kbuild test robot <fengguang.wu@intel.com>

Thanks,
Richard


Richard Cochran (7):
  timecounter: provide a macro to initialize the cyclecounter mask
    field.
  bnx2x: convert to CYCLECOUNTER_MASK macro.
  e1000e: convert to CYCLECOUNTER_MASK macro.
  igb: convert to CYCLECOUNTER_MASK macro.
  ixgbe: convert to CYCLECOUNTER_MASK macro.
  mlx4: include clocksource.h again
  microblaze: include the new timecounter header.

 arch/microblaze/kernel/timer.c                   |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |    3 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c         |    5 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    1 +
 include/linux/timecounter.h                      |    5 ++++-
 7 files changed, 11 insertions(+), 8 deletions(-)

-- 
1.7.10.4
