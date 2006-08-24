From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/4] Try 2 - Add wireless statistics to d80211 and its drivers
Date: Wed, 23 Aug 2006 21:51:12 -0500
Message-ID: <44ED1420.3090008@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:12697 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030191AbWHXCvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:51:18 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri,

This series of patches address all of your earlier concerns, namely:

1. The d80211 stuff is in Part 1/4, the patches for bcm43xx-d80211 are in Part 2/4, the patches for
the adm8211 driver is in Part 3/4, and the patches for the RT2X00 family of drivers are in Part 4/4.

2. The location for maxssi has been moved to struct hw.

3. The unnecessary variables in ieee80211_local have been removed. Unfortunately, wstats has to remain.

4. The floor for signal and noise has been set to -110 dBm.

5. The variables last_signal and last_noise now appear in /sys/class/ieee80211/phy0/sta/[MAC
Address]/. BTW, is there a good reason why only root can read these variables?

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>


