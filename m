From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 0/4] Introduce another options to set/get time with "ktime_t" type
Date: Thu, 19 Mar 2015 13:45:05 +0800
Message-ID: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org,
	baolin.wang@linaro.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series change the 32-bit time type (timespec) to the 64-bit one
(ktime_t), since 32-bit time types will break in the year 2038.

This patch series introduce another two optinos to set/get time with "ktime_t" type,
and remove the old ones with "timespec" type.

Next step will replace the other drivers' "timespec" type with "ktime_t" type.

Baolin Wang (4):
  ptp/chardev:Introduce another option to get/set time in
    ptp_clock_info structure
  ptp/clcok:Introduce the setktime/getktime interfaces with "ktime_t"
    type
  ptp/pch:Replace timespec with ktime_t in ptp_pch.c
  ptp/ixp46x:Replace timespec with ktime_t in ptp_ixp46x.c

 drivers/ptp/ptp_chardev.c        |   27 ++++++++++++++++++---------
 drivers/ptp/ptp_clock.c          |   20 ++++++++++++++++++--
 drivers/ptp/ptp_ixp46x.c         |   21 ++++++---------------
 drivers/ptp/ptp_pch.c            |   21 ++++++---------------
 include/linux/ptp_clock_kernel.h |    2 ++
 5 files changed, 50 insertions(+), 41 deletions(-)

-- 
1.7.9.5
