From: Max Uvarov <muvarov@gmail.com>
Subject: [PATCHv3 0/2] davinci_mdio: remove busy loop on wait user access
Date: Fri, 11 Aug 2017 13:57:39 +0300
Message-ID: <1502449061-30373-1-git-send-email-muvarov@gmail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        Max Uvarov <muvarov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:37809 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdHKK5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 06:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3: no code change, just added cover letter

First patch fixes cpu load on polling busy mdio line.
Second patch just prints which mdio frequency was configured.

Max Uvarov (2):
  drivers: net: davinci_mdio: remove busy loop on wait user access
  drivers: net: davinci_mdio: print bus frequency

 drivers/net/ethernet/ti/davinci_mdio.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

-- 
2.5.0
