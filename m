From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v4 ethtool 0/2] Add new Realtek devices
Date: Tue, 13 Aug 2013 23:25:17 +0200
Message-ID: <1376429119-31380-1-git-send-email-lekensteyn@gmail.com>
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	lekensteyn@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:39805 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758938Ab3HMVZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:25:25 -0400
Received: by mail-wi0-f170.google.com with SMTP id hi8so3480230wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:25:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The list of devices supported by `ethtool -d eth0` was quite outdated
and did not support my onboard NIC. With the following two patches, the
supported devices list will be in sync with the r8169 kernel driver
(r8169 as of 3.11). Note that no new registers have been added, I am
sure that some registers are incorrect (like the Power Management wakeup
frames), but important information such as MAC address is still correct.

This fourth revision corrects the name RTL8169C ("RTL8169C+") to
RTL8169Cp and corrects a wrongly changed identifier for the
RTL8169_8110SCe. (noticed by Ben Hutchings). The last mistake would not
affect the final result because it is changed in the second patch
("realtek: update devices to 3.11").

Regards,
Peter
--

Peter Wu (2):
  realtek: convert to per-chip mask
  realtek: update devices to 3.11

 realtek.c | 285 +++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 218 insertions(+), 67 deletions(-)

-- 
1.8.3.4
