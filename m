From: Marek Vasut <marex@denx.de>
Subject: [PATCH V2 0/4] Synchronise IFI CANFD driver with real world
Date: Wed,  2 Mar 2016 11:42:35 +0100
Message-ID: <1456915359-6775-1-git-send-email-marex@denx.de>
Cc: netdev@vger.kernel.org, Marek Vasut <marex@denx.de>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:42348 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbcCBKmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 05:42:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thus far, this driver was only tested on a hardware synthesised in
the warm and safe insides of an FPGA, only against another IFI CANFD
core. The real hardware arrived now and I tested the IFI CANFD driver
against different, harsh, real-world CAN controller.

This uncovered a few bugs, so here are the fixes for those.

Marek Vasut (4):
  net: can: ifi: Fix clock generator configuration
  net: can: ifi: Fix TX DLC configuration
  net: can: ifi: Fix RX and TX ID mask
  net: can: ifi: Add obscure bit swap for EFF frame IDs

 drivers/net/can/ifi_canfd/ifi_canfd.c | 93 ++++++++++++++++++++++-------------
 1 file changed, 60 insertions(+), 33 deletions(-)

V2: Address comments in the ML

-- 
2.7.0
