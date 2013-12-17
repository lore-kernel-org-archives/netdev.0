From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-12-17
Date: Tue, 17 Dec 2013 11:44:47 +0100
Message-ID: <1387277089-25554-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50837 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab3LQKo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 05:44:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request with two fixes for net/master, the current release
cycle.

It consists of a patch by Alexey Khoroshilov from the Linux Driver Verification
project, which fixes a memory leak in ems_usb's failure patch. And a patch by
me which fixes a memory leak in the peak usb driver.

regards,
Marc

---

The following changes since commit 9bd7d20c45157c175bfd45449e904a404506f99c:

  sctp: loading sctp when load sctp_probe (2013-12-16 20:04:27 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.13

for you to fetch changes up to 20fb4eb96fb0350d28fc4d7cbfd5506711079592:

  can: peak_usb: fix mem leak in pcan_usb_pro_init() (2013-12-17 11:19:33 +0100)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      can: ems_usb: fix urb leaks on failure paths

Marc Kleine-Budde (1):
      can: peak_usb: fix mem leak in pcan_usb_pro_init()

 drivers/net/can/usb/ems_usb.c               | 3 ++-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)
