From: Michael Buesch <mb@bu3sch.de>
Subject: Please pull bcm43xx-d80211 features and bugfixes
Date: Thu, 26 Oct 2006 21:10:23 +0200
Message-ID: <200610262110.23251.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:16036
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1423708AbWJZTLc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 15:11:32 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please pull latest bcm43xx-d80211 features and bugfixes.

git pull http://bu3sch.de/git/wireless-dev.git for-linville

This will introduce hardware encryption for everything
but TKIP on v4 firmware. For v3 firmware or TKIP it will
transparently fall back to software encryption.
It also fixes a bug that caused high CPU usage due to an IRQ
not stopping to trigger.


      bcm43xx-d80211: Fix runaway IRQ which caused high CPU usage.
      bcm43xx-d80211: Rename IRQs
      bcm43xx-d80211: Fix hardware based encryption for v4 firmware.
      bcm43xx-d80211: Use software encryption for TKIP for now.
      bcm43xx-d80211: No support for hw encryption with v3 firmware. Various hwenc fixes.
      bcm43xx-d80211: Only set USEDEFKEYS hostflag for WEP.

 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |  103 +++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |  488 +++++++++++++-------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h |    3 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |   93 +++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h |    2 
 5 files changed, 461 insertions(+), 228 deletions(-)

-- 
Greetings Michael.
