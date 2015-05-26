From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: phy: phy_interface_is_rgmii helper
Date: Tue, 26 May 2015 12:19:57 -0700
Message-ID: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, dmurphy@ti.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35383 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbEZTUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 15:20:32 -0400
Received: by pdea3 with SMTP id a3so97471429pde.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

As you suggested, here is the helper function to avoid missing some RGMII
interface checks. Had to wait for net to be merged in net-next to avoid
submitting the same patch/commit.

Dan, you might want to rebase your dp83867 submission to use that helper
when you this patchset gets merged into net-next, thanks!

Florian Fainelli (2):
  net: phy: Add phy_interface_is_rgmii helper
  net: phy: Utilize phy_interface_is_rgmii

 drivers/net/phy/icplus.c  |  5 +----
 drivers/net/phy/marvell.c | 10 ++--------
 drivers/net/phy/phy.c     |  3 +--
 include/linux/phy.h       | 11 +++++++++++
 4 files changed, 15 insertions(+), 14 deletions(-)

-- 
2.1.0
