From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/11 V2] rtlwifi: A set of patches that simplify the drivers
Date: Tue,  6 Jan 2015 09:58:01 -0600
Message-ID: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:58163 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbAFP6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:58:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Happy New Year.

This set of patches, which are intended for the 3.20 stream, are intended to
simplify the drivers. In particular, each of them has a separate routine that
initilizes the dynamic power manipulation variables. Ten of these patches convert
the drivers to use a common copy of this code. The other patch updates the
parameter descriptions of rtl8723be to clarify usage.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - only patch 02/11 is changed to fix the problem noted by Sergei Shylyov
     <sergei.shtylyov@cogentembedded.com> concerning a line that was dropped.

Larry Finger (11):
  rtlwifi: Unify variable naming for all drivers
  rtlwifi: rtl8723be: Improve modinfo output
  rtlwifi: Create new routine to initialize the DM tables
  rtlwifi: rtl8188ee: Convert driver to use the common DM table init
    routine
  rtlwifi: rtl8192c-common: Convert driver to use common DM table
    initialization
  rtlwifi: rtl8192de: Convert driver to use common DM table
    initialization
  rtlwifi: rtl8192ee: Convert driver to use common DM table
    initialization
  rtlwifi: rtl8723ae: Convert driver to use common DM table
    initialization
  rtlwifi: rtl8723be: Convert driver to use common DM table
    initialization
  rtlwifi: rtl8821ae: Convert driver to use common DM table
    initialization
  rtlwifi: Move macro definitions to core

 drivers/net/wireless/rtlwifi/core.c               | 37 +++++++++++++++
 drivers/net/wireless/rtlwifi/core.h               | 41 ++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c       | 36 ++------------
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h       | 41 ----------------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 45 ++++--------------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h | 38 ---------------
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h       | 13 -----
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       | 33 ++-----------
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h       | 38 ---------------
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c       | 55 ++++++---------------
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h       | 16 -------
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c       |  7 +--
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h       | 28 -----------
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c       | 42 ++++------------
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h       | 38 ---------------
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c       | 55 ++++++---------------
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h       | 33 -------------
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c       | 11 +++--
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c       | 58 +++++++----------------
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h       | 41 ----------------
 drivers/net/wireless/rtlwifi/wifi.h               |  2 -
 22 files changed, 157 insertions(+), 552 deletions(-)

-- 
2.1.2
