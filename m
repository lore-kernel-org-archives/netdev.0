From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v3 0/2] [ethtool] Add new Realtek devices
Date: Thu, 25 Jul 2013 15:36:29 +0200
Message-ID: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:46385 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3GYNgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:36:40 -0400
Received: by mail-wg0-f46.google.com with SMTP id k13so1633742wgh.1
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:36:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The list of devices supported by `ethtool -d eth0` was quite outdated
and did not support my onboard NIC. With the following two patches, the
supported devices list will be in sync with the r8169 kernel driver
(r8169 as of 3.11). Note that no new registers have been added, I am
sure that some registers are incorrect (like the Power Management wakeup
frames), but important information such as MAC address is still correct.

In this second revision of the patch (ignoring the wordwrap mixup), I
have incorporated Francois' suggestion to put align the chip names using
tabs and de-duplicate the `RTL-` prefixes. I have actually also changed
the chip names to be a little more consistent with the Realtek marketing
and r8169 names.

Regards,
Peter
--

Peter Wu (2):
  realtek: convert to per-chip mask
  realtek: update devices to 3.11

 realtek.c | 285 +++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 218 insertions(+), 67 deletions(-)

-- 
1.8.3.3
