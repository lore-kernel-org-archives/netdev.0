From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: dsa: bcm_sf2: misc bugfixes
Date: Tue, 25 Nov 2014 18:08:47 -0800
Message-ID: <1416967729-717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:61765 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaKZCIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:08:52 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1751526pdb.14
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:08:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains two bug fixes:

- first patch fixes an issue on the error path of the driver where we could
  have left some of our registers mapped

- second patch enforces the use of a software reset of the switch to guarantee
  the HW is in a consistent state prior to software initialization

Thanks!

Florian Fainelli (2):
  net: dsa: bcm_sf2: fix unmapping registers in case of errors
  net: dsa: bcm_sf2: reset switch prior to initialization

 drivers/net/dsa/bcm_sf2.c | 58 +++++++++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 25 deletions(-)

-- 
2.1.0
