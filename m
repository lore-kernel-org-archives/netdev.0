From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/11 NEXT] Modify rtlwifi, rtl_pci, rtl8188ee, and rtl8821ae for merge with Realtek code repo
Date: Mon, 22 Sep 2014 09:39:16 -0500
Message-ID: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:37096 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbaIVOju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:39:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches accomplish the following:

1. Update existing drivers to the level of the latest Realtek drivers from 06/28/2014
2. Move the updated rtl8821ae driver into the regular wireless tree. Removal of
   the staging version will be sent to GregKH once these patches are in place.
3. Make all this code match what is found in the Realtek code repo. Because of
   this, there is considerable churning of the code; however, the same is true
   for the Realtek repo. Once the two code bases are the same, incorporation
   of the Realtek updates and bug fixes will be a lot easier. In fact, if all
   goes well, I hope that Realtek can handle it without my interventikon.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (11):
  rtlwifi: Remove extra workqueue for enter/leave power state
  rtlwifi: rtl_pci: Start modification for new drivers
  rtlwifi: Modify core.c for new drivers
  rtlwifi: Modify base.{c,h} for new drivers
  rtlwifi: Modify cam.{c,h} and efuse.{c,h} for new drivers
  rtlwifi: Update power-save routines for 062814 driver
  rtlwifi: Finish modifying core routines for new drivers
  rtlwifi: rtl8188ee: Update driver to match Realtek release of 06282014
  rtlwifi: rtl8821ae: Move driver from staging to regular tree
  rtlwifi: Fix problems with building an allyesconfig
  rtlwifi: Fix Sparse warnings
